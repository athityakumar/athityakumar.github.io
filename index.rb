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
# javascript/search.js for local search updation. from C.

# Templates
# ---------
# index.html.erb > DONE
# blog_page.html.erb  > DONE
# blog_post.html.erb > DONE
# tag_page.html.erb > DONE

require 'json'

def generate_blog_pages
end

def generate_tags_pages
end

def generate_blog_posts
end

def generate_search_js
end

def get_posts
    posts = []
    files = Dir.entries("auto/data/posts").keep_if { |a| a.end_with? ".json" }
    files.each do |file|
        data = {}
        data = JSON.parse(File.read("auto/data/posts/#{file}"))[0] 
        data["filename"] = file.gsub(".json","")  
        posts.push(data)
    end
    return posts
end

def get_tags
    list = []
    tags = JSON.parse(File.read("auto/data/tags.json"))
    tags.each do |tag|
        filename = tag["name"].downcase.gsub(" ","_").gsub(",","").gsub("-","")
        data = tag
        data["filename"] = filename
        list.push(data)
    end
    return list
end

$posts = get_posts()
$tags = get_tags()

#Useful for pagination of 5 posts in 1 page
# a=[1,2,3,4,5,6,7,8,9,10]
# a.each_slice(3).to_a => [[1,2,3],[4,5,6],[7,8,9],[10]]