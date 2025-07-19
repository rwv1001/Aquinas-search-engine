import "@hotwired/turbo-rails"
// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
const _oldGlobalEval = jQuery.globalEval;

// override it
jQuery.globalEval = function( data ) {
  // if no code, do nothing
  if ( !data ) return;

  // create a script tag so CSP will allow it
  const script = document.createElement("script");
  script.text = data;
  
  // attach the nonce we exposed in window._cspNonce
  if (window._cspNonce) {
    script.nonce = window._cspNonce;
  }

  document.head.appendChild(script);
  document.head.removeChild(script);
};


import "controllers"
import "jquery"
import "crawler_page"

document.addEventListener("domain_summary:loaded", () => {
  SelectDomainAction();  
});
document.addEventListener("domain_summary:guest_loaded", () => {
  HideOptions();
});
document.addEventListener("index:user_loaded", () => {
  $(".search-new").show();
});
document.addEventListener("group:loaded", () => {
  SelectGroupAction();
  SelectDomainAction();
});

