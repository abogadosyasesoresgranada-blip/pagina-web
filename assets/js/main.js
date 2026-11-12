/* /assets/js/main.js - v2.1 (RGPD: solo cookies técnicas y de analítica) */
document.addEventListener("DOMContentLoaded", function () {
    
    // --- 1. LÓGICA DEL MENÚ MÓVIL ---
    const hamburgerBtn = document.getElementById('hamburgerBtn');
    const closeMenuBtn = document.getElementById('closeMenuBtn');
    const mobileMenu = document.getElementById('mobileMenu');

    function toggleMenu() {
        if (!mobileMenu) return;
        const isHidden = mobileMenu.hidden;
        mobileMenu.hidden = !isHidden;
        if (hamburgerBtn) hamburgerBtn.setAttribute('aria-expanded', isHidden ? 'true' : 'false'); // abierto ⇔ true
    }

    if (hamburgerBtn) {
        hamburgerBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            toggleMenu();
        });
    }

    if (closeMenuBtn) {
        closeMenuBtn.addEventListener('click', (e) => {
            e.stopPropagation();
            if (mobileMenu) mobileMenu.hidden = true;
            if (hamburgerBtn) hamburgerBtn.setAttribute('aria-expanded', 'false');
        });
    }

    // Cerrar al hacer clic fuera del menú
    document.addEventListener('click', (e) => {
        if (mobileMenu && !mobileMenu.hidden && !mobileMenu.contains(e.target) && hamburgerBtn && !hamburgerBtn.contains(e.target)) {
            mobileMenu.hidden = true;
            hamburgerBtn.setAttribute('aria-expanded', 'false');
        }
    });

    // Cerrar al pulsar en un enlace del menú
    if (mobileMenu) {
        mobileMenu.querySelectorAll('a').forEach(link => {
            link.addEventListener('click', () => {
                mobileMenu.hidden = true;
                if (hamburgerBtn) hamburgerBtn.setAttribute('aria-expanded', 'false');
            });
        });
    }

    // --- 2. GESTIÓN DE COOKIES (RGPD) ---
    const cookieBanner = document.getElementById("cookieBanner");
    const cookieSettings = document.getElementById("cookieSettings");
    const acceptBtn = document.getElementById("acceptCookies");
    const rejectBtn = document.getElementById("rechazoCookies");
    const optionsBtn = document.getElementById("opcionesBtn");
    const saveSettingsBtn = document.getElementById("confirmSettings");
    const closeCookieModals = document.querySelectorAll("#closeCookies, .cookie-settings__close, .cookie-settings__backdrop");
    
    // Comprobar estado inicial en localStorage
    const consent = localStorage.getItem("cookieConsent");
    
    // Si no hay consentimiento previo, mostramos el banner
    if (!consent && cookieBanner) {
        cookieBanner.style.display = "block"; 
    } else if (consent === "accepted" || (consent && consent.includes('"analitica":"Permitir"'))) {
        // Si aceptó todas o al menos las analíticas personalizadas, activamos GA
        activarAnalytics();
    } else if (consent) {
        // Consentimiento denegado: limpiamos posibles cookies de GA de visitas anteriores
        desactivarAnalytics();
    }

    function esconderModales() {
        if(cookieBanner) cookieBanner.style.display = "none";
        if(cookieSettings) cookieSettings.classList.add("d-none");
    }

    // Aceptar todo
    if (acceptBtn) {
        acceptBtn.addEventListener("click", () => {
            localStorage.setItem("cookieConsent", "accepted");
            esconderModales();
            activarAnalytics();
        });
    }

    // Rechazar todo
    if (rejectBtn) {
        rejectBtn.addEventListener("click", () => {
            localStorage.setItem("cookieConsent", "rejected");
            esconderModales();
            desactivarAnalytics();
        });
    }

    // Abrir opciones de personalización
    if (optionsBtn) {
        optionsBtn.addEventListener("click", () => {
            if(cookieSettings) cookieSettings.classList.remove("d-none");
        });
    }

    // Guardar preferencias personalizadas
    function guardarPreferencias() {
        const analitica = document.querySelector('input[name="cookiesAnalitica"]:checked')?.value || 'Denegar';
        localStorage.setItem("cookieConsent", JSON.stringify({ analitica }));

        esconderModales();

        // Solo activamos analytics si lo permitió explícitamente; si no, se retira
        if (analitica === 'Permitir') {
            activarAnalytics();
        } else {
            desactivarAnalytics();
        }
    }

    // Botón "Guardar" (index) ...
    if (saveSettingsBtn) {
        saveSettingsBtn.addEventListener("click", guardarPreferencias);
    }
    // ... y formulario "Guardar preferencias" (páginas interiores, botón type="submit")
    document.querySelectorAll(".cookie-settings__form").forEach(form => {
        form.addEventListener("submit", (e) => {
            e.preventDefault();
            guardarPreferencias();
        });
    });

    // "Rechazar todo" / "Aceptar todo" dentro del panel de preferencias
    const rejectAllBtn = document.getElementById("rechazatAll");
    const acceptAllBtn = document.getElementById("deacuerdoAll");
    if (rejectAllBtn) {
        rejectAllBtn.addEventListener("click", () => {
            localStorage.setItem("cookieConsent", "rejected");
            esconderModales();
            desactivarAnalytics();
        });
    }
    if (acceptAllBtn) {
        acceptAllBtn.addEventListener("click", () => {
            localStorage.setItem("cookieConsent", "accepted");
            esconderModales();
            activarAnalytics();
        });
    }

    // Cerrar modales con la 'X' o haciendo clic fuera del modal (backdrop)
    closeCookieModals.forEach(btn => {
        btn.addEventListener("click", () => {
            if(cookieSettings) cookieSettings.classList.add("d-none");
            
            // Si cierran la 'X' del banner principal sin aceptar, se asume rechazo (RGPD estricto)
            if (btn.id === 'closeCookies' && cookieBanner) {
                cookieBanner.style.display = "none";
                if (!localStorage.getItem("cookieConsent")) {
                    localStorage.setItem("cookieConsent", "rejected");
                }
            }
        });
    });

    // --- 3. GOOGLE ANALYTICS (INYECCIÓN DINÁMICA) ---
    function activarAnalytics() {
        window['ga-disable-G-M2P2728TZL'] = false; // por si se había retirado en esta misma visita
        if (window.gaActivo) return; // Evitar doble inyección
        window.gaActivo = true;
        
        const script = document.createElement('script');
        script.src = "https://www.googletagmanager.com/gtag/js?id=G-M2P2728TZL";
        script.async = true;
        document.head.appendChild(script);

        window.dataLayer = window.dataLayer || [];
        function gtag(){dataLayer.push(arguments);}
        window.gtag = gtag; // Hacerlo accesible globalmente
        
        gtag('js', new Date());
        gtag('config', 'G-M2P2728TZL', {
            'anonymize_ip': true // Anonimización de IP obligatoria en Europa
        });
    }
    
    // Retirada del consentimiento: detiene GA4 y borra sus cookies (_ga, _ga_*)
    function desactivarAnalytics() {
        window['ga-disable-G-M2P2728TZL'] = true;
        const dominio = location.hostname.replace(/^www\./, '');
        document.cookie.split(';').forEach(function (c) {
            const nombre = c.split('=')[0].trim();
            if (/^_ga(_|$)/.test(nombre)) {
                document.cookie = nombre + '=; Max-Age=0; path=/';
                document.cookie = nombre + '=; Max-Age=0; path=/; domain=' + dominio;
            }
        });
    }

    // --- 4. FIX MAILTO (Previene errores de renderizado pasivo en Móviles) ---
    const mailtoLinks = document.querySelectorAll('a[href^="mailto:"]');
    mailtoLinks.forEach(link => {
        link.addEventListener("click", function(e) {}, { passive: true });
    });

    // --- 5. SEGUIMIENTO DE CONVERSIONES (GA4) — respeta el consentimiento ---
    // Solo envía si el usuario ACEPTÓ cookies (window.gtag existe tras activarAnalytics()).
    // NO se recoge ningún dato personal: únicamente el método de contacto y la ruta de la página.
    function registrarContacto(metodo, destino) {
        if (typeof window.gtag !== "function") return; // sin consentimiento -> no se mide
        window.gtag("event", "generar_contacto", {
            metodo: metodo,                    // telefono | whatsapp | email | formulario
            destino: destino || "",            // nº PROPIO del despacho / 'whatsapp' (dato del negocio, no del usuario)
            pagina: window.location.pathname   // qué landing generó el contacto
        });
    }

    // 5.1 Clics en teléfono, WhatsApp y email (delegación: cubre también enlaces inyectados)
    document.addEventListener("click", function (e) {
        const a = e.target.closest("a[href]");
        if (!a) return;
        const href = a.getAttribute("href") || "";
        if (href.startsWith("tel:")) {
            registrarContacto("telefono", href.replace("tel:", ""));
        } else if (/wa\.me|whatsapp/i.test(href)) {
            registrarContacto("whatsapp", "whatsapp");
        } else if (href.startsWith("mailto:")) {
            registrarContacto("email", "email");
        }
    }, { passive: true });

    // 5.2 Envío de formularios (SOLO el hecho de enviar; nunca el contenido de los campos)
    // (se excluye el formulario de preferencias de cookies: no es un contacto)
    document.querySelectorAll("form:not(.cookie-settings__form)").forEach(function (form) {
        form.addEventListener("submit", function () {
            registrarContacto("formulario", form.getAttribute("id") || form.getAttribute("name") || "");
        }, { passive: true });
    });
});