document.addEventListener("DOMContentLoaded", () => {
    if (window.hljs) {
        window.hljs.highlightAll();
    }

    const menu = document.querySelector(".course-menu");
    if (!menu) {
        return;
    }

    const toggle = menu.querySelector("summary");
    const currentFile = window.location.pathname.split("/").pop();

    menu.querySelectorAll("a[href]").forEach((link) => {
        const linkedFile = link.getAttribute("href").split("/").pop();
        if (linkedFile === currentFile) {
            link.classList.add("active");
            link.setAttribute("aria-current", "page");
        }
    });

    menu.addEventListener("toggle", () => {
        document.body.classList.toggle("menu-open", menu.open);
    });

    document.addEventListener("click", (event) => {
        if (!menu.open) {
            return;
        }

        const clickedInsidePanel = event.target.closest(".sidebar");
        const clickedToggle = event.target.closest(".menu-toggle");
        if (!clickedInsidePanel && !clickedToggle) {
            menu.removeAttribute("open");
        }
    });

    document.addEventListener("keydown", (event) => {
        if (event.key === "Escape" && menu.open) {
            menu.removeAttribute("open");
            toggle.focus();
        }
    });
});
