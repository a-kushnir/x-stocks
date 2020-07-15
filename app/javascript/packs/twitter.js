function twitterWidget() {
    window.twttr = (function (d, s, id) {
        var t, js, fjs = $("body");
        if (d.getElementById(id)) return;
        js = d.createElement(s); js.id = id;
        js.src= "https://platform.twitter.com/widgets.js";
        $(fjs).append(js, fjs);
        return window.twttr || (t = { _e: [], ready: function (f) { t._e.push(f)  }  });
    }(document, "script", "twitter-wjs"));
};
$(document).on('turbolinks:load', twitterWidget);
