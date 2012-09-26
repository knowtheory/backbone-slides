$(document).ready(function(){
  window.commentDialog = null;
  slides = new SlideList();
  navi = new SlideNavigation({ el: 'aside.controls', collection: slides });
  slides.fetch();
});