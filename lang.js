// privacy.html, support.html 언어 전환. 우선순위: ?lang= → 저장한 선택 → 브라우저 언어
(function () {
  var supported = ['ko', 'en'];
  var store = {
    get: function () { try { return localStorage.getItem('lang'); } catch (e) { return null; } },
    set: function (v) { try { localStorage.setItem('lang', v); } catch (e) {} }
  };
  var param = new URLSearchParams(location.search).get('lang');
  var lang = [param, store.get(), (navigator.language || '').slice(0, 2) === 'ko' ? 'ko' : 'en']
    .filter(function (l) { return supported.indexOf(l) >= 0; })[0];

  function apply(l) {
    document.documentElement.lang = l;
    document.querySelectorAll('main > div[lang]').forEach(function (d) { d.hidden = d.lang !== l; });
    document.querySelectorAll('.lang button').forEach(function (b) {
      b.setAttribute('aria-pressed', b.dataset.lang === l);
    });
    // 다른 페이지로 가는 링크에도 언어를 이어 붙인다
    document.querySelectorAll('footer a').forEach(function (a) {
      var base = a.getAttribute('href').split('?')[0];
      if (/\.html$/.test(base)) a.setAttribute('href', base + '?lang=' + l);
    });
  }

  document.querySelectorAll('.lang button').forEach(function (b) {
    b.onclick = function () {
      store.set(b.dataset.lang);
      history.replaceState(null, '', '?lang=' + b.dataset.lang);
      apply(b.dataset.lang);
    };
  });
  apply(lang);
})();
