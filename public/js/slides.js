$(document).ready(function(){
  Reveal.addEventListener( 'slidechanged', function( event ) {
      // event.previousSlide, event.currentSlide, event.indexh, event.indexv
      console.log(Reveal.getIndices().h);
      commentDialog.close()
  } );
});