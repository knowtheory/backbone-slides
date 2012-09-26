Slide.auto_migrate!
data = [
  { 
  :format => :markdown,
  :body => <<-BODY
# Backbone.js &amp; Underscore.js
BODY
  },
  {
    :format => :markdown,
    :body => <<-BODY
# Ted Han
## @knowtheory
## ted@documentcloud.org
BODY
  },
  {
    :format => :markdown,
    :body => <<-BODY
# DocumentCloud
## Investigative Reporters &amp; Editors
BODY
  },
  {
    :format => :markdown,
    :body => <<-BODY
# Models & Collections
## Managing data
BODY
  },
  {
    :format => :markdown,
    :body => <<-BODY
# Views
## UI/DOM & User Interaction
BODY
  }
]

data.each{ |d| Slide.create(d) }
