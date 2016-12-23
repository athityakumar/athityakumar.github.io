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
# blog/index.html from A,B,C,D 
# blog/tag/*/page*/index.html
# blog/post/*/index.html
# blog/page*/index.html
# javascript/home.js for typed_string
# javascript/search.js for local search updation

# Templates
# ---------
# index.html.erb > DONE
# blog_page.html.erb  > DONE
# blog_post.html.erb > DONE
# tag_page.html.erb
