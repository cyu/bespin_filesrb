class DirWalker
  attr_accessor :ignores
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
        full_fn  = File.join(dir, fn)
        if File.exists?(full_fn) && !%w(. ..).include?(fn)
          path << fn
          rel_path = path.join('/')
          if File.file?(full_fn)
            result << rel_path
          else
            do_walk(full_fn) unless ignore?(rel_path)
          end
          path.pop
        end
      end
    end

    def ignore?(fn) 
      !ignores.nil? && !!ignores.detect{|i| i.match(fn)}
    end
end
