
class ClassDuplicates
  Data = Struct.new(:classes, :files)

  class Finder
    MATCHER = %r{
      class\s*\=\s*["']?([\w\s\-_:]+)["']?|          # class = "hello world"
      class\:\s*["']?([\w\s\-_:]+)["']?|             # class: 'hello world'
      ["']?class["']?\s=>\s*["']?([\w\s\-_:]+)["']?  # 'class' => "hello world"
    }x.freeze
    WHITESPACE = %r{\s}.freeze

    def self.call(file_name)
      content = File.read(file_name)
      matches = content.scan(Finder::MATCHER).map(&:compact).flatten

      matches.map do |match|
        classes = match.split(WHITESPACE).reject(&:empty?)
        next if classes.empty?

        Data.new(classes.map(&:downcase).sort, [file_name])
      end.compact
    end
  end

  class Merger
    def self.call(entities)
      entities.group_by { |entity| entity.classes }.map do |classes, items|
        Data.new(classes, items.map(&:files).flatten)
      end
    end
  end

  class Filter
    def self.call(entities)
      entities.select do |entity|
        entity.classes.size > 1 && entity.files.size > 1
      end
    end
  end

  class Printer
    def self.call(entities)
      entities.sort_by { |entity| [-entity.files.size, -entity.classes.size] }.each do |entity|
        puts "#{entity.files.size} matches for \"#{entity.classes.join(" ")}\""
        entity.files.uniq.sort.each do |file_name|
          puts "  #{file_name}"
        end
        puts
      end
    end
  end

  def execute
    entities = []

    Dir.glob("**/*.html.erb") do |file_name|
      entities.concat(Finder.(file_name))
    end

    entities = Merger.(entities)
    entities = Filter.(entities)
    Printer.(entities)
  end
end

ClassDuplicates.new.execute
