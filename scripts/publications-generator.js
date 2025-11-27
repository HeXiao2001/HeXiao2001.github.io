hexo.extend.generator.register('publications', function(locals) {
  var newsTag = locals.tags.findOne({name: 'News'});
  var posts = [];
  
  if (newsTag) {
    posts = newsTag.posts.sort('-date').toArray();
  }

  var mappedPosts = posts.map(function(post, index) {
    // Use Object.create to shadow properties without modifying the original post
    var newPost = Object.create(post);
    
    // Add numbering to title (Reverse order: Newest gets highest number)
    newPost.title = '[' + (posts.length - index) + '] ' + post.title;
    
    var coverImage = '';
    var imgStyle = 'width: 200px; max-width: 100%; height: auto; margin-bottom: 10px; border-radius: 5px; display: block; box-shadow: 0 2px 5px rgba(0,0,0,0.1);';
    
    // 1. Check for 'cover' in front-matter
    if (post.cover) {
       if (post.cover.match(/^https?:\/\//)) {
         coverImage = '<img src="' + post.cover + '" style="' + imgStyle + '">';
       } else {
         var root = hexo.config.root || '/';
         if (!root.endsWith('/')) root += '/';
         var path = post.path; 
         coverImage = '<img src="' + root + path + post.cover + '" style="' + imgStyle + '">';
       }
    } 
    // 2. If no cover, try to find first image in content
    else {
      var mdMatch = post.content.match(/!\[.*?\]\((.*?)\)/);
      var htmlMatch = post.content.match(/<img [^>]*src="([^"]+)"[^>]*>/);
      var src = '';
      if (mdMatch) {
        src = mdMatch[1];
      } else if (htmlMatch) {
        src = htmlMatch[1];
      }
      
      if (src) {
         if (!src.match(/^https?:\/\//) && !src.startsWith('/')) {
             var root = hexo.config.root || '/';
             if (!root.endsWith('/')) root += '/';
             var path = post.path;
             src = root + path + src;
         }
         coverImage = '<img src="' + src + '" style="' + imgStyle + '">';
      }
    }

    if (coverImage) {
        var text = post.description || post.excerpt || '';
        if (post.description) {
            text = '<p>' + text + '</p>';
        }
        // Flex layout: Image Left, Text Right
        newPost.excerpt = '<div style="display: flex; align-items: flex-start; gap: 20px;">' + 
                          '<div style="flex-shrink: 0;">' + coverImage + '</div>' + 
                          '<div style="flex-grow: 1;">' + text + '</div>' + 
                          '</div>';
        newPost.description = ''; 
    }
    
    return newPost;
  });

  // Wrap in a proxy object to satisfy Nunjucks/Hexo template requirements
  var postsProxy = {
      toArray: function() { return mappedPosts; },
      length: mappedPosts.length,
      each: function(cb) { mappedPosts.forEach(cb); },
      forEach: function(cb) { mappedPosts.forEach(cb); }
  };

  return {
    path: 'publications/index.html',
    data: {
      posts: postsProxy,
      title: 'Publications',
      total: 1,
      current: 1,
      base: '/publications/',
      prev: 0,
      next: 0,
      is_home: false,
      is_archive: false,
      is_category: false,
      is_tag: false,
      is_news: false
    },
    layout: ['index']
  };
});
