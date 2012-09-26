var SlideView = Backbone.View.extend({
  
});

var CommentDialog = Backbone.View.extend({
  events: {
    'click .go': 'save',
    'click .cancel': 'close',
    'focus input'     : '_addFocus',
    'focus textarea'  : '_addFocus',
    'blur input'      : '_removeFocus',
    'blur textarea'   : '_removeFocus'
  },
  initialize:   function(options) {
  },
  _addFocus:    function(e) {
    
  },
  _removeFocus: function(e) {
    
  },
  render: function() {
    var commentHTML = this.collection.reduce(function(memo, comment){ return memo + "<p>" + comment.get('body') + "</p>"; }, '');
    this.$el.html(JST['comment_dialog']({comment_list: commentHTML}));
    this.$el.show();
  },
  save: function(e) {
    var body = this.$el.find('textarea').val();
    if (body.length > 0) {
      var comment = new Comment({ body: body, slide_id: this.collection.slide.id });
      comment.save();
      this.collection.add(comment);
      this.$el.find('textarea').val('');
      this.render();
    }
  },
  close: function(e) {
    this.$el.hide();
  }
});

var SlideNavigation = Backbone.View.extend({
  tagName: 'aside', 
  className: 'controls',
  initialize: function(options) {
    this.collection.on('reset', this.render, this);
    this.commentButton = new CommentButton({collection: this.collection});
    this.on('slide_change', this.test, this);
  },
  render: function() {
    this.renderCommentButton();
    this.commentButton.render();
  },
  renderCommentButton: _.once(function(){
    this.$el.append('<a class="comments">&#x25C9;</a>');
    this.commentButton.setElement(this.$el.find('.comments'));
  }),
  test: function() { console.log("Slide Changed!"); }
});

var CommentButton = Backbone.View.extend({
  tagName: "a",
  events: { 'click' : 'openCommentDialog' },
  render: function() {
    var numberMap = {
      1:"&#x278A;",
      2:"&#x278B;",
      3:"&#x278C;",
      4:"&#x278D;",
      5:"&#x278E;",
      6:"&#x278F;",
      7:"&#x2790;",
      8:"&#x2791;",
      9:"&#x2792;",
      10:"&#x2793;"
    };
    var slide = this.collection.currentSlide();
    var notice = "&#x272A";
    if (slide.comments.size() === 0) {
      notice = "&#x25C9;";
    } else if (slide.comments.size() <= 10 ) {
      notice = numberMap[slide.comments.size()];
    } 
    this.$el.html(notice);
  },
  openCommentDialog: function(event) {
    if (commentDialog) { commentDialog.dispose(); }
    commentDialog = new CommentDialog({collection: this.collection.currentSlide().comments, el: 'div.comments'});
    commentDialog.render();
  }
});