hexo.extend.generator.register('news', function(locals) {
  var newsTag = locals.tags.findOne({name: 'News'});
  var posts = [];
  
  if (newsTag) {
    posts = newsTag.posts.sort('-date').toArray();
  }

  var mappedPosts = posts.map(function(post) {
    // Use Object.create to shadow properties without modifying the original post
    var newPost = Object.create(post);
    
    var coverImage = '';
    
    // 1. Check for 'cover' in front-matter
    if (post.cover) {
       if (post.cover.match(/^https?:\/\//)) {
         coverImage = '<img src="' + post.cover + '" style="width:100%; max-width: 100%; margin-bottom: 20px; border-radius: 5px; display: block;">';
       } else {
         var root = hexo.config.root || '/';
         if (!root.endsWith('/')) root += '/';
         var path = post.path; 
         coverImage = '<img src="' + root + path + post.cover + '" style="width:100%; max-width: 100%; margin-bottom: 20px; border-radius: 5px; display: block;">';
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
         coverImage = '<img src="' + src + '" style="width:100%; max-width: 100%; margin-bottom: 20px; border-radius: 5px; display: block;">';
      }
    }

    if (coverImage) {
        var text = post.description || post.excerpt || '';
        if (post.description) {
            text = '<p>' + text + '</p>';
        }
        newPost.excerpt = coverImage + text;
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
    path: 'news/index.html',
    data: {
      posts: postsProxy,
      title: 'News',
      total: 1,
      current: 1,
      base: '/news/',
      prev: 0,
      next: 0,
      is_home: false,
      is_archive: false,
      is_category: false,
      is_tag: false,
      is_news: true
    },
    layout: ['index']
  };
});
