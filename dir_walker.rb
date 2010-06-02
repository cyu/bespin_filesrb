class DirWalker
  attr_reader :path, :result

  def initialize(*path)
    @path = path
  end

  def walk(dir)
    @result = []
    do_walk(dir)
    result
  end

  protected
    def do_walk(dir)
      Dir.foreach(dir) do |fn|
        full_fn = File.join(dir, fn)
        if File.exists?(full_fn) && !%w(. ..).include?(fn)
          path << fn
          if File.file?(full_fn)
            result << path.join('/')
          else
            do_walk(full_fn)
          end
          path.pop
        end
      end
    end
end