require 'test_helper'

class CommandsTest < MiniTest::Spec
  let(:step_file) { test_file('stepping') }
  let(:break_first_file) { test_file('break1') }
  let(:break_second_file) { test_file('break2') }

  before do
    Pry.color = false
    Pry.pager = false
    Pry.hooks = Pry::DEFAULT_HOOKS
    @output = StringIO.new
  end

  describe 'Step Command' do
    describe 'single step' do
      before do
        @input = InputTester.new 'step'
        redirect_pry_io(@input, @output) do
          load step_file
        end
      end

      it 'shows current line' do
        @output.string.must_match /\=> 4:/
      end
    end

    describe 'multiple step' do
      before do
        @input = InputTester.new 'step 2'
        redirect_pry_io(@input, @output) do
          load step_file
        end
      end

      it 'shows current line' do
        @output.string.must_match /\=>  9:/
      end
    end
  end

  describe 'Next Command' do
    describe 'single step' do
      before do
        @input = InputTester.new 'next'
        redirect_pry_io(@input, @output) do
          load step_file
        end
      end

      it 'shows current line' do
        @output.string.must_match /\=> 3:/
      end
    end

    describe 'multiple step' do
      before do
        @input = InputTester.new 'next 2'
        redirect_pry_io(@input, @output) do
          load step_file
        end
      end

      it 'shows current line' do
        @output.string.must_match /\=> 22:/
      end
    end
  end

  describe 'Finish Command' do
    before do
      @input = \
        InputTester.new 'break 16', 'continue', 'finish', 'break --delete-all'
      redirect_pry_io(@input, @output) do
        load step_file
      end
    end

    it 'goes to correct line' do
      @output.string.must_match /\=> 12:/
    end
  end

  describe 'Set Breakpoints' do
    before do
      @input = InputTester.new 'break --delete-all'
      redirect_pry_io(@input, @output) do
        load break_first_file
      end
    end

    describe 'set by line number' do
      before do
        @input = InputTester.new 'break 4'
        redirect_pry_io(@input, @output) do
          load break_first_file
        end
      end

      it 'shows breakpoint enabled' do
        @output.string.must_match /^Breakpoint [\d]+: #{break_first_file} @ 4 \(Enabled\)/
      end

      it 'shows breakpoint hit' do
        @output.string =~ /^Breakpoint ([\d]+): #{break_first_file} @ 4 \(Enabled\)/
        @output.string.must_match Regexp.new("^Breakpoint #{$1}\. First hit")
      end

      it 'shows breakpoint line' do
        @output.string.must_match /\=> 4:/
      end
    end

    describe 'set by method_id' do
      before do
        @input = InputTester.new 'break BreakExample#a'
        redirect_pry_io(@input, @output) do
          load break_first_file
        end
      end

      it 'shows breakpoint enabled' do
        @output.string.must_match /^Breakpoint [\d]+: BreakExample#a \(Enabled\)/
      end

      it 'shows breakpoint hit' do
        @output.string =~ /^Breakpoint ([\d]+): BreakExample#a \(Enabled\)/
        @output.string.must_match Regexp.new("^Breakpoint #{$1}\. First hit")
      end

      it 'shows breakpoint line' do
        @output.string.must_match /\=> 4:/
      end

      describe 'when its a bang method' do
        before do
          @input = InputTester.new 'break BreakExample#c!'
          redirect_pry_io(@input, @output) do
            load break_first_file
          end
        end

        it 'shows breakpoint enabled' do
          @output.string.must_match /^Breakpoint [\d]+: BreakExample#c! \(Enabled\)/
        end

        it 'shows breakpoint hit' do
          @output.string =~ /^Breakpoint ([\d]+): BreakExample#c! \(Enabled\)/
          @output.string.must_match Regexp.new("^Breakpoint #{$1}\. First hit")
        end

        it 'shows breakpoint line' do
          @output.string.must_match /\=> 14:/
        end
      end
    end

    describe 'set by method_id within context' do
      before do
        @input = InputTester.new 'break #b'
        redirect_pry_io(@input, @output) do
          load break_second_file
        end
      end

      it 'shows breakpoint enabled' do
        @output.string.must_match /^Breakpoint [\d]+: BreakExample#b \(Enabled\)/
      end

      it 'shows breakpoint hit' do
        @output.string =~ /^Breakpoint ([\d]+): BreakExample#b \(Enabled\)/
        @output.string.must_match Regexp.new("^Breakpoint #{$1}\. First hit")
      end

      it 'shows breakpoint line' do
        @output.string.must_match /\=>  8:/
      end
    end
  end
end

