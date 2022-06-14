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
    $('#individual_collected').datepicker({
        dateFormat: 'yy-mm-dd'
    });

    renderMap();
});

function renderMap() {
    $.ajax({
        type: "GET",
        contentType: "application/json; charset=utf-8",
        url: 'locality',
        dataType: 'json',
        data: {
            root_id: $('#taxonomy_root_select option:selected').val()
        },
        success: function (data) {
            var map = L.map('map').setView([data.latitude, data.longitude], 10);

            // Please check the Open Street Map Tile Usage Policy to see if you might need to use a different tile layer
            // provider for your implementation:
            // https://operations.osmfoundation.org/policies/tiles/
            L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
                maxZoom: 15,
                attribution: '© <a href="https://www.openstreetmap.org/copyright" target="_blank">OpenStreetMap</a>'
            }).addTo(map);

            var marker = L.marker([data.latitude, data.longitude]).addTo(map);
            marker.bindPopup("Latitude: " + data.latitude
                + "<br>Longitude: " + data.longitude
                + "<br>Elevation: " + data.elevation);

            var localityTab = document.getElementById('locality');
            var observer1 = new MutationObserver(function(){
                if(localityTab.style.display != 'none'){
                    map.invalidateSize();
                }
            });
            observer1.observe(localityTab, {attributes: true});
        },
        error: function (_result) {
            console.error("Error getting data.");
        }
    });
}