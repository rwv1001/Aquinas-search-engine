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
document.addEventListener("hideforms", () => {
  console.log("hideforms event received, calling HideForms()");
  console.log("HideForms function available:", typeof window.HideForms);
  console.log("jQuery available:", typeof $ !== 'undefined');
  
  function executeHideForms() {
    if (typeof window.HideForms === 'function' && typeof $ !== 'undefined') {
      window.HideForms();
      return true;
    }
    return false;
  }
  
  // Try immediately
  if (!executeHideForms()) {
    console.log("Functions not ready, retrying...");
    // Retry with delays
    setTimeout(executeHideForms, 100);
    setTimeout(executeHideForms, 500);
  }
});

