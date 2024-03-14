/**
 * 
 */

function onWindowLoaded(event) {
    let div = window.document.createElement("div");
    div.textContent = "> window loaded!";
    window.document.body.appendChild(div);
}

window.addEventListener("load", onWindowLoaded);
