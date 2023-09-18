window.onloadTurnstileCallback = function () {
    turnstile.render('#container', {
        sitekey: '${sitekey}',
        callback: function(token) {
            const request = new XMLHttpRequest();
            request.open("POST", "//${domain}/api/protect", false);
            request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
            request.send("token="+token);
            document.write(request.responseText);
        },
    });
};