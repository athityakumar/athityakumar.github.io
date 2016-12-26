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

def remove_dir path
    if File.directory?(path)
        Dir.foreach(path) do |file|
        if ((file.to_s != ".") and (file.to_s != ".."))
                remove_dir("#{path}/#{file}")
            end
        end
        Dir.delete(path)
    else
        File.delete(path)
    end
    puts "Removing previous blog path : #{path}/."
end

def make_dir path
    Dir.mkdir(path)
    puts "Making new blog path : #{path}/"
end

def get_posts_tagged tag
    list = []
    $posts.each do |post|
        if post["tags"].include? tag["index"]
            list.push(post)
        end
    end
    return list
end

def setup_paths
    make_dir("blog")
    make_dir("blog/posts")
    make_dir("blog/tags")    
    n_blog_pages = $posts.each_slice($per_page).to_a.count
    for i in (1..n_blog_pages)
        make_dir("blog/page#{i}")
    end
    $posts.each do |post|
        make_dir("blog/posts/#{post["filename"]}")
    end

    $tags.each do |tag|
        make_dir("blog/tags/#{tag["filename"]}")
        n_tag_pages = get_posts_tagged(tag).each_slice($per_page).to_a.count
        for i in (1..n_tag_pages)
            make_dir("blog/tags/#{tag["filename"]}/page#{i}")
        end
    end
end

def do_pagination posts , tag 
    # Requires template too
    #type = "b for blog or t for rag"
    n_pages = posts.each_slice($per_page).to_a.count
    n_posts = posts.count
    for i in (0..n_posts-1)
        posts[i]["index"] = (i+1).to_s
    end
    for i in (0..n_pages-1)
        posts_in_page = posts.each_slice($per_page).to_a[i]
        showing_posts = [$per_page*i+1, (($per_page*(i+1) > n_posts) ? n_posts : ($per_page*(i+1)))]
        if i!=0
            recent_page_exists = true
            recent_page = i
        else
            recent_page_exists = false
            recent_page = "NIL"
        end 
        if i!=n_pages-1
            older_page_exists = true
            older_page = i+2
        else
            older_page_exists = false
            older_page = "NIL"
        end       

        if tag.length == 0
            # html_text = HtmlBeautifier.beautify((File.exists? "auto/templates/blogpage.html.erb") ? ERB.new(File.open("auto/templates/blogpage.html.erb").read, 0, '>').result(binding) : "")
            # File.open("blog/page#{i+1}/index.html", "w") { |file| file.write(html_text) }
            puts "Generating Blog page #{i+1}."
        else
            # html_text = HtmlBeautifier.beautify((File.exists? "auto/templates/blogtagpage.html.erb") ? ERB.new(File.open("auto/templates/blogtagpage.html.erb").read, 0, '>').result(binding) : "")
            # File.open("blog/tag/#{tag["name"]}/page#{i+1}/index.html", "w") { |file| file.write(html_text) }
            puts "Generating page #{i+1} of Tag #{tag["name"]}."
        end
    end
end

def generate_blog_pages
    do_pagination($posts,"")
end

def generate_tags_pages
    $tags.each do |tag|
        tagged_posts = get_posts_tagged(tag)
        do_pagination(tagged_posts,tag)
    end
end

def generate_blog_posts
    tempate = "auto/templates/blogpost.html.erb"
    for i in (0..$posts.count-1)
        if i!=0
            next_post_exists = true
            next_post_link = $posts[i-1]["filename"]
        else
            next_post_exists = false
            next_post_link = "NIL"
        end 
        if i!=$posts.count-1
            prev_post_exists = true
            prev_post_link = $posts[i+1]["filename"]
        else
            prev_post_exists = false
            prev_post_link = "NIL"
        end
        post = $posts[i]    
        html_file = "blog/posts/#{post["filename"]}/index.html"
        puts "Generating blog post - #{post["filename"]}."
        html_text = HtmlBeautifier.beautify((File.exists? tempate) ? ERB.new(File.open(tempate).read, 0, '>').result(binding) : "")
        File.open(html_file, "w") { |file| file.write(html_text) }
    end
end

def generate_homepage
end

def get_random_key
    return ('a'..'z').to_a.shuffle[0..100].join
end

def unique_disqus_identifier
    posts , filename = [] , []
    files = Dir.entries("auto/data/posts").keep_if { |a| a.end_with? ".json" }
    files.each do |file|
        posts.push(JSON.parse(File.read("auto/data/posts/#{file}"))[0])
        filename.push(file)
    end
    n = posts.count
    for i in (0..n-1)
        existing_keys = posts.map { |r| r["disqus_identifier"] }.uniq
        if posts[i]["disqus_identifier"].nil?
            random = get_random_key()
            while existing_keys.include? random
                random = get_random_key()
            end
            posts[i]["disqus_identifier"] = random
            data = posts[i]
            File.open("auto/data/posts/#{filename[i]}", "w") { |file| file.write(JSON.pretty_generate([data])) }
        end
    end
end

def get_posts
    posts = []
    files = Dir.entries("auto/data/posts").keep_if { |a| a.end_with? ".json" }

    files.each do |file|
        data = {}
        data = JSON.parse(File.read("auto/data/posts/#{file}"))[0] 
        data["filename"] = file.gsub(".json","").gsub(" ","_") 
        posts.push(data)
        data["date"] = data["datetime_index"][6..7] + "/" + data["datetime_index"][4..5] + "/" + data["datetime_index"][0..3]
        if data["datetime_index"][8..9].to_i > 12 
            data["time"] =  (data["datetime_index"][8..9].to_i - 12).to_s + ":" + data["datetime_index"][10..11] + " PM"
        else
            data["time"] = data["datetime_index"][8..9] + ":" + data["datetime_index"][10..11] + " AM" 
        end
        data["tag_data"] = []
        $tags.each do |t|
            if data["tags"].include? t["index"]
                data["tag_data"].push(t)
            end
        end
    end
    posts = posts.sort_by { |row| row["datetime_index"].to_i }
    posts = posts.reverse
    puts "Reading and manipulating all posts from json format."
    return posts
end

def get_unused_tags 
    $tags.each do |tag|
        flag = 0
        data = tag
        $posts.each do |post|
            if post["tags"].include? tag["index"]
                flag = 1
            end
        end
        if flag == 0
            puts "Tag #{tag["name"]} is not used on any post, and is still there in tags.json file. Take care of it."
        end
    end
end

def get_tags
    list = []
    tags = JSON.parse(File.read("auto/data/tags.json"))
    tags.each do |tag|
        filename = tag["name"].gsub(" ","_")
        data = tag
        data["filename"] = filename
        list.push(data)
    end
    puts "Reading & manipulating all tags from json format."
    return list
end

$per_page = 5
unique_disqus_identifier()
$tags = get_tags()
$posts = get_posts()
get_unused_tags()
remove_dir("blog")
setup_paths()
generate_blog_pages()
generate_tags_pages()
generate_blog_posts()
# generate_homepage()