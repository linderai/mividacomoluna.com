// auth-guard.js — Mi Vida Como Luna
// Guards any page at any depth under docs/
// Token key: luna_token (sessionStorage only)
(function () {
    var token = sessionStorage.getItem('luna_token');
    if (!token) {
        var base = (location.pathname.match(/^(.*\/docs\/)/) || ['', '/'])[1];
        window.location.replace(base + 'login/');
    }
})();
