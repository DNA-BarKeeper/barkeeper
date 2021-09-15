jQuery(function() {
    if (document.getElementById("lightboxModal") != null) {
        var modal = document.getElementById("lightboxModal");
        var modalImg = document.getElementById("lightboxImage");
        var captionText = document.getElementById("caption");

        $('img.docImage').click(function () {
            modal.style.display = "block";
            modalImg.src = this.src;
            captionText.innerHTML = this.alt;
        });

        $(document).click(function (event) {
            // If you click on anything except the modal itself, close the modal
            if (!$(event.target).closest(".modal-content, .caption-container, .docImage").length) {
                modal.style.display = "none";
            }
        });

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
