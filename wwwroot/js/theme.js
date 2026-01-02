window.theme = {
    get: () => 'dark',
    apply: () => {
        if (typeof document === 'undefined') return;
        document.body.classList.remove('theme-light', 'theme-dark');
        document.body.classList.add('theme-dark');
        document.documentElement.setAttribute('data-theme', 'dark');
        localStorage.setItem('gg-theme', 'dark');
    }
};
