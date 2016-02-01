require 'stringio'
require 'tempfile'
require 'fileutils'

module RunWithTimer

  def self.capture_stdout(output)
    previous_stdout, $stdout = $stdout, $stdout.reopen(output, 'w')
    yield
  ensure
    $stdout = previous_stdout
  end

  def self.capture_with_timer(command, output)
    capture_stdout(output) do
      system("#{command} | gawk '{ x=\"'\"`date +%s%3N`\"'\"; printf \"[%s] %s\\n\", x, $0; fflush(); }'")
      system("echo FIN | gawk '{ x=\"'\"`date +%s%3N`\"'\"; printf \"[%s] %s\\n\", x, $0; fflush(); }'")
    end

    get_durations(output)
  end


  # calculate the elapsed time by calculating the difference between timestamp and current and the next line
  def self.get_durations(output)

    temp_file = Tempfile.new('runwtimer')

    File.open(output, 'r+') do |file|
      lines = file.readlines
      length = lines.length

      # performs the calculation and replaces original timestamp with elapsed time
      (0..length-2).each do |i|
        current_time = get_time(lines[i])
        next_time = get_time(lines[i+1])
        difference = next_time - current_time
        lines[i] = lines[i].sub(/#{current_time}/, "elapsed time: #{difference} ms")
      end

      # delete the timestamp on the last line
      lines[length-1] = lines[length-1].gsub(/\A\[[[:digit:]]+\] /, '')

      temp_file.puts(lines)
      temp_file.close
      # replace the file with the temporary file
      FileUtils.mv(temp_file.path, output)
    end
  end

  def self.get_time(line)
    /\A\[([[:digit:]]+)/.match(line)[1].to_i
  end
end