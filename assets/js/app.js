// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import ApexCharts from "apexcharts";

// ESCHARTS
let Hooks = {};
Hooks.Chart = {
  mounted() {
    selector = "#" + this.el.id;
    options = JSON.parse(this.el.querySelector(selector + "-data").textContent);
    options.tooltip = {
      x: {
        formatter: function(value) {
          return "£" + value.toLocaleString();
        },
      },
    };
    var chart = new ApexCharts(
      document.querySelector(selector + "-chart"),
      options,
    );
    chart.render();
  },
};

Hooks.Line = {
  mounted() {
    selector = "#" + this.el.id;
    options = JSON.parse(
      this.el.querySelector(selector + "-series").textContent,
    );
    options.tooltip = {
      y: {
        formatter: function(value) {
          return "£" + value.toLocaleString();
        },
      },
    };
    var options = {
      series: [{
        name: "Total",
        data: options,
      }],
      chart: {
        height: 350,
        type: "line",
        zoom: {
          enabled: false,
        },
      },
      dataLabels: {
        enabled: false,
      },
      stroke: {
        curve: "straight",
      },
      title: {
        text: "Spending in last 30 days",
        align: "left",
      },
      grid: {
        row: {
          colors: ["#f3f3f3", "transparent"], // takes an array which will be repeated on columns
          opacity: 0.5,
        },
      },
      xaxis: {
        categories: [
          "Jan",
          "Feb",
          "Mar",
          "Apr",
          "May",
          "Jun",
          "Jul",
          "Aug",
          "Sep",
        ],
      },
    };

    var chart = new ApexCharts(
      document.querySelector(selector + "-chart"),
      options,
    );
    chart.render();
  },
};
Hooks.Pie = {
  mounted() {
    selector = "#" + this.el.id;
    labels = JSON.parse(
      this.el.querySelector(selector + "-labels").textContent,
    );
    series = JSON.parse(
      this.el.querySelector(selector + "-series").textContent,
    );

    const arrayOfDecimals = series.map((str) => str / 100);

    var options = {
      series: arrayOfDecimals,
      chart: {
        width: 500,
        type: "pie",
      },
      labels: labels,
      tooltip: {
        y: {
          formatter: function(value) {
            return "£" + value.toLocaleString();
          },
        },
      },
      responsive: [{
        breakpoint: 480,
        options: {
          chart: {
            width: 200,
          },
          legend: {
            position: "bottom",
          },
        },
      }],
    };
    var chart = new ApexCharts(
      document.querySelector(selector + "-chart"),
      options,
    );
    chart.render();
  },
};

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute(
  "content",
);
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
