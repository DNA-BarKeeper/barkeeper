/*
 * BarKeeper - A versatile web framework to assemble, analyze and manage DNA
 * barcoding data and metadata.
 * Copyright (C) 2022 Kai Müller <kaimueller@uni-muenster.de>, Sarah Wiechers
 * <sarah.wiechers@uni-muenster.de>
 *
 * This file is part of BarKeeper.
 *
 * BarKeeper is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * BarKeeper is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with BarKeeper.  If not, see <http://www.gnu.org/licenses/>.
 */

jQuery(function() {
    if (document.getElementById("lightboxModal") != null) {
        var modal = document.getElementById("lightboxModal");
        var modalImg = document.getElementById("modal-image");
        var captionText = document.getElementById("caption");


        $('img.lightbox-image').click(function () {
            modal.style.display = "block";
            modalImg.src = this.src;
            captionText.innerHTML = this.alt;

            if (document.getElementById("remove_image_modal_button") != null) {
                document.getElementById("remove_image_modal_button").style.display = "block";
            }
        });

        $(document).click(function (event) {
            // If you click on anything except the modal itself, close the modal
            if (!$(event.target).closest(".modal-content, .caption-container, .lightbox-image").length) {
                modal.style.display = "none";
            }
        });

        if (document.getElementById("remove_image") != null) {
            var remove_button = document.getElementById("remove_image");
            remove_button.style.display = "block";
        }

        // Get the <span> element that closes the modal
        var span = document.getElementsByClassName("close-icon")[0];

        // When the user clicks on <span> (x), close the modal
        span.onclick = function () {
            modal.style.display = "none";
        }

        // Support closing modal via keyboard
        document.body.addEventListener('keydown', function logEventKey(e) {
            if (e.key === 'Escape') {
                modal.style.display = "none";
            }
        });
    }
});
