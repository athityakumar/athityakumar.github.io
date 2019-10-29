# frozen_string_literal: true

# Files associated -

# Input
# -----
# A -> config/data/metadata.json (later)
# B -> config/data/config.json (later)
# C -> config/data/posts/*.json
# D -> config/data/tags.json

# Output
# ------
# index.html from A,B
# blog/tag/*/page*/index.html for every D[1], for every C[5]. from A,B,C,D
# blog/post/*/index.html for every C[1]. from A,B,C,D
# blog/page*/index.html for every C[5]. from A,B,C,D

# Templates
# ---------
# index.html.erb >
# blog_page.html.erb  >
# blog_post.html.erb >
# tag_page.html.erb >

require 'json'
require 'erb'
require 'htmlbeautifier'
require 'yaml'
require 'redcarpet'

def remove_dir(path)
  if File.directory?(path)
    Dir.foreach(path) do |file|
      remove_dir("#{path}/#{file}") if (file.to_s != '.') && (file.to_s != '..')
    end
    Dir.delete(path)
  else
    File.delete(path)
  end
  puts "Removing previous blog path : #{path}/."
rescue StandardError
  puts "Can't remove blog directory"
end

def make_dir(path)
  Dir.mkdir(path)
  puts "Making new blog path : #{path}/"
end

def fetch_posts_tagged(tag)
  list = []
  $posts.each do |post|
    list.push(post) if post['tags'].include? tag['index']
  end
  list
end

def setup_paths
  make_dir('blog')
  make_dir('blog/posts')
  make_dir('blog/tags')
  n_blog_pages = $posts.each_slice($per_page).to_a.count
  (1..n_blog_pages).each do |i|
    make_dir("blog/page_#{i}")
  end
  $posts.each do |post|
    make_dir("blog/posts/#{post['filename']}")
  end

  $tags.each do |tag|
    make_dir("blog/tags/#{tag['filename']}")
    n_tag_pages = fetch_posts_tagged(tag).each_slice($per_page).to_a.count
    n_tag_pages = n_tag_pages.zero? ? 1 : n_tag_pages
    (1..n_tag_pages).each do |i|
      make_dir("blog/tags/#{tag['filename']}/page_#{i}")
    end
  end
end

def do_pagination(posts, tag)
  n_pages = posts.each_slice($per_page).to_a.count
  n_posts = posts.count
  (0..n_posts-1).each do |i|
    posts[i]['index'] = (n_posts-i).to_s
  end
  if n_pages != 0
    (0..n_pages-1).each do |i|
      posts_in_page = posts.each_slice($per_page).to_a[i]
      showing_posts = [posts_in_page.first['index'], posts_in_page.last['index']].reverse
      j = i
      if i!=0
        recent_page_exists = true
        recent_page = i
      else
        recent_page_exists = false
        recent_page = 'NIL'
      end
      if i!=n_pages-1
        older_page_exists = true
        older_page = i+2
      else
        older_page_exists = false
        older_page = 'NIL'
      end
      template = 'auto/templates/pagination.html.erb'
      html_text = HtmlBeautifier.beautify(File.exist?(template) ? ERB.new(File.open(template).read, 0, '>').result(binding) : '')
      if tag.empty?
        File.open("blog/page_#{j+1}/index.html", 'w') { |file| file.write(html_text) }
        puts "Generating Blog page #{j+1}."
      else
        File.open("blog/tags/#{tag['filename']}/page_#{j+1}/index.html", 'w') { |file| file.write(html_text) }
        puts "Generating page #{j+1} of Tag #{tag['name']}."
      end
    end
  else
    i = 0
    n_pages = 1
    posts_in_page = []
    showing_posts = [0,0]
    older_page_exists, recent_page_exists = false, false
    template = 'auto/templates/pagination.html.erb'
    html_text = HtmlBeautifier.beautify(File.exist?(template) ? ERB.new(File.open(template).read, 0, '>').result(binding) : '')
    if tag.empty?
      File.open('blog/page_1/index.html', 'w') { |file| file.write(html_text) }
      puts 'Generating Blog page 1.'
    else
      File.open("blog/tags/#{tag['filename']}/page_1/index.html", 'w') { |file| file.write(html_text) }
      puts "Generating page 1 of Tag #{tag['name']}."
    end
  end
end

def generate_blog_pages
  do_pagination($posts,'')
end

def generate_tags_pages
  $tags.each do |tag|
    tagged_posts = fetch_posts_tagged(tag)
    do_pagination(tagged_posts,tag)
  end
end

def generate_blog_posts
  template = 'auto/templates/blogpost.html.erb'
  (0..$posts.count-1).each do |i|
    if i!=0
      next_post_exists = true
      next_post_link = $posts[i-1]['filename']
    else
      next_post_exists = false
      next_post_link = 'NIL'
    end
    if i!=$posts.count-1
      prev_post_exists = true
      prev_post_link = $posts[i+1]['filename']
    else
      prev_post_exists = false
      prev_post_link = 'NIL'
    end
    post = $posts[i]
    j = i
    html_file = "blog/posts/#{post['filename']}/index.html"
    puts "Generating blog post - #{post['filename']}."
    html_text = HtmlBeautifier.beautify(File.exist?(template) ? ERB.new(File.open(template).read, 0, '>').result(binding) : '')
    File.open(html_file, 'w') { |file| file.write(html_text) }
  end
end

def generate_homepage; end

def fetch_random_key
  ('a'..'z').to_a.sample(101).join
end

def unique_disqus_identifier
  posts, filename = [], []
  identifier = File.exist?('auto/data/disqus.json') ? JSON.parse(File.read('auto/data/disqus.json')) : {}
  files = Dir.entries('auto/data/posts').keep_if { |a| a.end_with? '.yml' }
  files.each do |file|
    posts.push(YAML.safe_load(File.read("auto/data/posts/#{file}")))
    filename.push(file)
  end
  existing_names = identifier.keys.uniq
  existing_keys = identifier.values.uniq
  filename.each do |file|
    next if existing_names.include? file

    random = fetch_random_key
    random = fetch_random_key while existing_keys.include? random
    identifier[file] = random
  end
  File.open('auto/data/disqus.json', 'w') { |file| file.write(JSON.pretty_generate(identifier)) }

  # n = posts.count
  # for i in (0..n-1)
  #     existing_keys = posts.map { |r| r["disqus_identifier"] }.uniq
  #     if posts[i]["disqus_identifier"].nil?
  #         random = fetch_random_key()
  #         while existing_keys.include? random
  #             random = fetch_random_key()
  #         end
  #         posts[i]["disqus_identifier"] = random
  #         File.open("auto/data/posts/#{filename[i]}", 'w') { |f| f.write posts[i].to_yaml }
  #         # File.open("auto/data/posts/#{filename[i]}", "w") { |file| file.write(JSON.pretty_generate([data])) }
  #     end
  # end
end

# def initialize_empty_fields data
#     fields = ["datetime_index","title","short_desc","tags=a","image_preview","images=a","html_content","disqus_identifier"]
#     fields.each do |f|
#         if data[f].nil?
#             if f.include? "=a"
#                 data[f.gsub("=a","")] = []
#             else
#                 data[f] = ""
#             end
#         end
#     end
#     return data
# end

def fetch_posts
  posts = []
  disqus = JSON.parse(File.read('auto/data/disqus.json'))
  files = Dir.entries('auto/data/posts').keep_if { |a| a.end_with? '.yml' }
  blog_img_dir = 'assets/images/blog'
  Dir.mkdir(blog_img_dir) unless Dir.exist? blog_img_dir
  files.each do |file|
    data = {}
    data = YAML.safe_load(File.read("auto/data/posts/#{file}"))
    # File.open("auto/data/posts/#{file}", "w") { |file| file.write(JSON.pretty_generate([initialize_empty_fields(data)])) }
    data['filename'] = file.gsub('.yml','').gsub(' ','_')
    posts.push(data)
    data['disqus_identifier'] = disqus[data['filename']]
    data['date'] = data['datetime_index'][6..7] + '/' + data['datetime_index'][4..5] + '/' + data['datetime_index'][0..3]
    data['time'] = if data['datetime_index'][8..9].to_i > 12
                     (data['datetime_index'][8..9].to_i - 12).to_s + ':' + data['datetime_index'][10..11] + ' PM'
                   else
                     data['datetime_index'][8..9] + ':' + data['datetime_index'][10..11] + ' AM'
                   end
    data['tag_data'] = []
    image_dir = "assets/images/blog/#{data['filename']}"
    if Dir.exist? image_dir
      data['image_preview'] = '' unless File.exist? "#{image_dir}/#{data['image_preview']}"
    else
      Dir.mkdir("assets/images/blog/#{data['filename']}")
    end
    data['html_content'] = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(
        no_intra_emphasis: true,
        tables: true,
        autolink: true,
        strikethrough: true,
        with_toc_data: true
      )
    ).render(data['html_content'])
    data['html_content'] = data['html_content']
                           .gsub('<a',"<a target='_blank'")
                           .gsub('<img src="',"<img src='#{$lazy_load_img}' class='ui centered image' data-src=\"../../../assets/images/blog/#{data['filename']}/")
                           .gsub('<ul>',"<h4> <ul class='ui list'>")
                           .gsub('</ul>','</ul> </h4>')
                           .gsub('<code',"<code class='language-ruby' style='background-color : #fff;'")
                           .gsub('</code>','</code></pre>')
    i = 1
    first = data['html_content'].split('<p>')[i][0]
    while first == '<'
      i += 1
      first = data['html_content'].split('<p>')[i][0]
    end
    data['html_content'] = data['html_content'].sub("<p>#{first}","<p><span style='display:block; float:left; font-size: 200%;  color:#ffffff; margin-top:5px; margin-right:8px; padding: 10px 20px 10px 20px; text-align:center; background-color: #000;'>#{first}</span>")
    str = data['html_content']
    rep_i = 0
    while str.include? '---'
      text_inbetween = str.split('---')[1]

      if rep_i.zero?
        str.sub!('---', "<br><div class='ui horizontal divider' id='#{text_inbetween}'>")
      else
        str.sub!('---', '</div>')
      end
      rep_i = rep_i == 1 ? 0 : 1
    end
    data['html_content'] = str
    $tags.each do |t|
      data['tag_data'].push(t) if data['tags'].include? t['index']
    end
  end
  posts = posts.sort_by { |row| row['datetime_index'].to_i }
  posts = posts.reverse
  puts 'Reading and manipulating all posts from json format.'
  posts
end

def fetch_unused_tags
  $tags.each do |tag|
    flag = 0
    $posts.each do |post|
      flag = 1 if post['tags'].include? tag['index']
    end
    puts "Unused tag : #{tag['name']}." if flag.zero?
  end
end

def fetch_tags
  list = []
  tags = JSON.parse(File.read('auto/data/tags.json'))
  tags.each do |tag|
    filename = tag['name'].gsub(' ','_').downcase
    data = tag
    data['filename'] = filename
    list.push(data)
  end
  puts 'Reading & manipulating all tags from json format.'
  list
end

# def liquid_markdown_to_html
# 2.3.1 :013 > renderer = Redcarpet::Render::HTML.new(render_options = {})
#  => #<Redcarpet::Render::HTML:0x000000014c7b00 @options={}>
# 2.3.1 :014 > markdown = Redcarpet::Markdown.new(renderer, extensions = {})
#  => #<Redcarpet::Markdown:0x000000014afb18 @renderer=#<Redcarpet::Render::HTML:0x000000014c7b00 @options={}>
# 2.3.1 :015 > markdown.render("This is *bongos*, indeed.")
#  => "<p>This is <em>bongos</em>, indeed.</p>\n"
# end

$lazy_load_img = '../../../assets/images/load.png'
$per_page = 5
unique_disqus_identifier
$tags = fetch_tags
$posts = fetch_posts
remove_dir('blog')
setup_paths
generate_blog_pages
generate_tags_pages
generate_blog_posts
# generate_homepage()
fetch_unused_tags
