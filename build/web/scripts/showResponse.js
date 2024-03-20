/*
To display an error add in <div id="error-alert"></div>
To display an success add in <div id="success-alert"></div>
To display an notice add in <div id="notice-alert"></div>
Code for URL param handling:

<script>
    let params = (new URL(document.location)).searchParams;
    let response = params.get("response");

    if (response == "incorrect-password") {
        showError("Incorrect email or password.");
        params.delete('response');
        window.history.replaceState({}, document.title, url.toString());
        // history.replaceState(null, null, window.location.pathname);
        // Above line also works, clears all URL params so I'm not using it.
    }
</script>
*/
function showError(message) {
    var errorAlert = document.getElementById('error-alert');
    errorAlert.innerHTML = message;
    errorAlert.style.display = "block";
    errorAlert.style.animation = 'none';
    errorAlert.offsetHeight;
    errorAlert.style.animation = null; 
    window.location.hash = 'error-alert';
}
function showSuccess(message) {
    var successAlert = document.getElementById('success-alert');
    successAlert.innerHTML = message;
    successAlert.style.display = "block";
    successAlert.style.animation = 'none';
    successAlert.offsetHeight;
    successAlert.style.animation = null; 
    window.location.hash = 'sucess-alert';
}
function showNotice(message) {
    var noticeAlert = document.getElementById('notice-alert');
    noticeAlert.innerHTML = message;
    noticeAlert.style.display = "block";
    noticeAlert.style.animation = 'none';
    noticeAlert.offsetHeight;
    noticeAlert.style.animation = null; 
    window.location.hash = 'notice-alert';
}
