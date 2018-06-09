window.onload = function () {
  var app = new Vue({
    el: '#app',
    data: {
     lat1: -37.57037203,
     lon1: 144.25295244,
     lat2: -37.39101561,
     lon2: 143.55353839,
     el_dist: null,
     azi1to2: null,
     azi2to1: null
    },
    methods: {
      getvincenty: function() {
        this.searching = true;
        fetch(endpoint, {
          method: 'POST',
          headers: new Headers(),
          body: JSON.stringify({
            "coords": [
              {"lat1": this.lat1, "lon1": this.lon2, "lat2": this.lat2, "lon2": this.lon2}
            ]
          })
        })
        .then(res => res.json())
        .then(res => {
          console.log(res);
          this.el_dist = res.vincinv[0]['el_dist'];
          this.azi1to2 = res.vincinv[0]['azi1to2'];
          this.azi2to1 = res.vincinv[0]['azi2to1'];
        });
      }
    }
  })
}
