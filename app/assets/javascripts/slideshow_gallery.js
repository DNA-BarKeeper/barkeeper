/*
 * Barcode Workflow Manager - A web framework to assemble, analyze and manage DNA
 * barcode data and metadata.
 * Copyright (C) 2020 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
 * <sarah.wiechers@uni-muenster.de>
 *
 * This file is part of Barcode Workflow Manager.
 *
 * Barcode Workflow Manager is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * Barcode Workflow Manager is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with Barcode Workflow Manager.  If not, see
 * <http://www.gnu.org/licenses/>.
 */

jQuery(function() {
    // Slideshow gallery with lightbox
    function openModal() {
        document.getElementById("myModal").style.display = "block";
    }

    function closeModal() {
        document.getElementById("myModal").style.display = "none";
    }

    // Next/previous controls
    function plusSlides(n) {
        showSlides(slideIndex += n);
    }

    function currentSlide(n) {
        showSlides(slideIndex = n);
    }

    function showSlides(n) {
        var i;
        var slides = document.getElementsByClassName("mySlides");
        var modalSlides = document.getElementsByClassName("modalSlides");

        var dots = document.getElementsByClassName("dot");
        var captionText = document.getElementById("caption");

        var remove_buttons = document.getElementsByClassName("remove-image");
        var remove_buttons_modal = document.getElementsByClassName("remove-image-modal");

        if (n > slides.length) {slideIndex = 1}
        if (n < 1) {slideIndex = slides.length}

        for (i = 0; i < slides.length; i++) {
            slides[i].style.display = "none";
            modalSlides[i].style.display = "none";
        }
        for (i = 0; i < dots.length; i++) {
            dots[i].className = dots[i].className.replace(" dot-active", "");
        }

        for (i = 0; i < remove_buttons.length; i++) {
            remove_buttons[i].style.display = "none";
            remove_buttons_modal[i].style.display = "none";
        }
        slides[slideIndex-1].style.display = "block";
        modalSlides[slideIndex-1].style.display = "block";

        remove_buttons[slideIndex-1].style.display = "block";
        remove_buttons_modal[slideIndex-1].style.display = "block";

        dots[slideIndex-1].className += " dot-active";
        captionText.innerHTML = slides[slideIndex-1].title;
    }

    if (document.getElementById("slideshow-wrapper") != null) {
        var slideIndex = 1;
        showSlides(slideIndex);
    }

    $('a.prev-button').click(function() { plusSlides(-1) });
    $('a.next-button').click(function() { plusSlides(1) });

    $('span.dot').click(function() {
        var index = parseInt(this.getAttribute("data-index"));
        currentSlide(index);
    });

    $('img.preview-image').click(function() {
        openModal();
        var index = parseInt(this.getAttribute("data-index"));
        currentSlide(index);
    });

    $(document).click(function(event) {
        // If you click on anything except the modal itself, close the modal
        if (!$(event.target).closest(".modalSlides,.preview-image,.next-button,.prev-button").length) {
            closeModal();
        }
    });

    // Support changing slides and closing modal via keyboard
    document.body.addEventListener('keydown', function logEventKey(e) {
        switch (e.key) {
            case 'ArrowLeft':
                plusSlides(-1);
                break;
            case 'ArrowRight':
                plusSlides(1);
                break;
            case 'Escape':
                closeModal();
                break;
        }
    });
});
