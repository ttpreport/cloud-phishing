function onSubmit(e) {
    e.preventDefault();
    const request = new XMLHttpRequest();
    request.open("POST", "//${domain}/api/process", false);
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded')
    request.send("email="+e.target.elements.email.value);
    window.location.replace(
        "https://example.com/",
    );
}