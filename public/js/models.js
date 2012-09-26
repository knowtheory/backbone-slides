var User = Backbone.Model.extend({
  initialize: function(attributes) {
    
  }
});

var Comment = Backbone.Model.extend({
  url: function() { return "/slides/" + this.get('slide_id') + "/comments"; },
  initialize: function(attributes) {
    
  }
});

var CommentList = Backbone.Collection.extend({
  url: function(){ return '/slides/' + this.slide.id + '/comments' },
  model: Comment,
  initialize: function(attributes, options) {
    this.slide = options.slide
  }
});

var Slide = Backbone.Model.extend({
  initialize: function(attributes) {
    if (attributes.comments) {
      this.comments = new CommentList(attributes.comments, {slide: this});
    }
  }
});

var SlideList = Backbone.Collection.extend({
  url: '/slides',
  model: Slide,
  initialize: function(attributes, options) {
    
  },
  currentSlide: function() {
    return this.find(function(slide){ return (slide.id - 1) == Reveal.getIndices().h; });
  }
});