require 'yaml'
require 'redcarpet'
yaml = YAML.load(File.read("in.yaml"))
md = yaml.delete "html"
puts yaml
puts "\n\n"
puts Redcarpet::Markdown.new(Redcarpet::Render::HTML.new).render(md)

str = "--- Hey --- # --- Hello ---"
pattern = /---.*?---/
str.sub(pattern) {|match| "yay " + match.split(" ")[1] + " no" }

