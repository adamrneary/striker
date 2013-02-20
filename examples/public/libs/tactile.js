/*! tactile - v0.0.1 - 2013-02-13
* https://github.com/activecell/tactile
* Copyright (c) 2013 Activecell; Licensed  */

(function (){
var Tactile = window.Tactile || {};
window.Tactile = Tactile;
var Tooltip;

Tactile.Tooltip = Tooltip = (function() {

  Tooltip._spotlightMode = false;

  Tooltip.turnOffspotlight = function() {
    return Tooltip._spotlightMode = false;
  };

  Tooltip.spotlightOn = function(d) {
    return Tooltip._spotlightMode = true;
  };

  Tooltip.getSpotlight = function() {
    return Tooltip._spotlightMode;
  };

  function Tooltip(el, options) {
    this.el = el;
    this.options = options;
    this.el = d3.select(this.el);
    this.annotate();
  }

  Tooltip.prototype.appendTooltip = function() {
    var chartContainer, tip;
    chartContainer = d3.select(this.options.graph._element);
    if (Tooltip._spotlightMode && this.el.node().classList.contains("active")) {
      tip = chartContainer.select('.tooltip');
    } else {
      chartContainer.selectAll('.tooltip').remove();
      tip = chartContainer.append('div').classed("tooltip", true);
      tip.append('div').html(this.options.text).classed("tooltip-inner", true);
    }
    return tip;
  };

  Tooltip.prototype.annotate = function() {
    var chartContainer, mouseMove, moveTip,
      _this = this;
    chartContainer = this.el.node().nearestViewportElement;
    if (this.options.tooltipCircleContainer) {
      this.tooltipCircleContainer = this.options.tooltipCircleContainer;
    } else if (this.options.circleOnHover) {
      this.tooltipCircleContainer = this.el.node().parentNode;
    }
    moveTip = function(tip) {
      var center, hoveredNode;
      center = [0, 0];
      if (_this.options.placement === "mouse") {
        center = d3.mouse(_this.options.graph._element);
      } else {
        if (_this.options.position) {
          center[0] = _this.options.position[0];
          center[1] = _this.options.position[1];
        } else {
          hoveredNode = _this.el.node().getBBox();
          center[0] = hoveredNode.x + hoveredNode.width / 2;
          center[1] = hoveredNode.y;
        }
        if (_this.el.node().tagName === 'circle') {
          center[1] += hoveredNode.height / 2 - 1;
        }
        center[0] += _this.options.graph.margin.left;
        center[0] += _this.options.graph.padding.left;
        center[1] += _this.options.graph.margin.top;
        center[1] += _this.options.graph.padding.top;
      }
      if (_this.options.displacement) {
        center[0] += _this.options.displacement[0];
        center[1] += _this.options.displacement[1];
      }
      return tip.style("left", "" + center[0] + "px").style("top", "" + center[1] + "px").style("display", "block");
    };
    this.el.on("mouseover", function() {
      var inner, tip;
      if (Tooltip._spotlightMode) {
        if (!_this.el.node().classList.contains("active")) {
          return;
        }
      }
      tip = _this.appendTooltip();
      if (_this.options.circleOnHover) {
        _this._appendTipCircle();
      }
      tip.classed("annotation", true).classed(_this.options.gravity, true).style("display", "none");
      if (_this.options.fade) {
        tip.classed('fade', true);
      }
      tip.append("div").attr("class", "arrow");
      tip.select('.tooltip-inner').html(_this.options.text);
      inner = function() {
        return tip.classed('in', true);
      };
      setTimeout(inner, 10);
      tip.style("display", "");
      return moveTip(tip);
    });
    mouseMove = function() {
      return d3.select(".annotation").call(moveTip.bind(this));
    };
    if (this.options.mousemove) {
      this.el.on("mousemove", mouseMove);
    }
    return this.el.on("mouseout", function() {
      var remover, tip;
      if (Tooltip._spotlightMode) {
        return;
      }
      d3.select(_this.tooltipCircleContainer).selectAll("circle.tooltip-circle").remove();
      if (_this.el.node().tagName === 'circle') {
        _this.el.classed('tip-hovered', false);
        _this.el.attr('stroke', _this.el.attr('data-stroke-color'));
        _this.el.attr('fill', _this.el.attr('data-fill-color'));
      }
      tip = d3.selectAll(".annotation").classed('in', false);
      remover = function() {
        return tip.remove();
      };
      return setTimeout(remover, 150);
    });
  };

  Tooltip.prototype._appendTipCircle = function() {
    var hoveredNode;
    hoveredNode = this.el.node().getBBox();
    if (this.el.node().tagName === 'circle') {
      if (!this.el.attr('data-stroke-color')) {
        this.el.attr('data-stroke-color', this.el.attr('stroke'));
      }
      if (!this.el.attr('data-fill-color')) {
        this.el.attr('data-fill-color', this.el.attr('fill'));
      }
      this.el.attr('fill', this.el.attr('data-stroke-color'));
      return this.el.attr('stroke', this.el.attr('data-fill-color'));
    } else {
      return d3.select(this.tooltipCircleContainer).append("svg:circle").attr("cx", hoveredNode.x + hoveredNode.width / 2).attr("cy", hoveredNode.y).attr("r", 4).attr('class', 'tooltip-circle').attr("stroke", this.options.circleColor || 'orange').attr("fill", 'white').attr("stroke-width", '1');
    }
  };

  return Tooltip;

})();

d3.selection.prototype.tooltip = function(f) {
  var options, selection;
  selection = this;
  options = {};
  return selection.each(function(d, i) {
    options = f.apply(this, arguments);
    return new Tactile.Tooltip(this, options);
  });
};

var FixturesTime;

Tactile.FixturesTime = FixturesTime = (function() {

  function FixturesTime() {
    var _this = this;
    this.tzOffset = new Date().getTimezoneOffset() * 60;
    this.months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    this.units = [
      {
        name: "decade",
        seconds: 86400 * 365.25 * 10,
        formatter: function(d) {
          return parseInt(d.getUTCFullYear() / 10) * 10;
        }
      }, {
        name: "year",
        seconds: 86400 * 365.25,
        formatter: function(d) {
          return d.getUTCFullYear();
        }
      }, {
        name: "month",
        seconds: 86400 * 30.5,
        formatter: function(d) {
          return _this.months[d.getUTCMonth()];
        }
      }, {
        name: "week",
        seconds: 86400 * 7,
        formatter: function(d) {
          return _this.formatDate(d);
        }
      }, {
        name: "day",
        seconds: 86400,
        formatter: function(d) {
          return d.getUTCDate();
        }
      }, {
        name: "6 hour",
        seconds: 3600 * 6,
        formatter: function(d) {
          return _this.formatTime(d);
        }
      }, {
        name: "hour",
        seconds: 3600,
        formatter: function(d) {
          return _this.formatTime(d);
        }
      }, {
        name: "15 minute",
        seconds: 60 * 15,
        formatter: function(d) {
          return _this.formatTime(d);
        }
      }, {
        name: "minute",
        seconds: 60,
        formatter: function(d) {
          return d.getUTCMinutes();
        }
      }, {
        name: "15 second",
        seconds: 15,
        formatter: function(d) {
          return d.getUTCSeconds() + "s";
        }
      }, {
        name: "second",
        seconds: 1,
        formatter: function(d) {
          return d.getUTCSeconds() + "s";
        }
      }
    ];
  }

  FixturesTime.prototype.unit = function(unitName) {
    return this.units.filter(function(unit) {
      return unitName === unit.name;
    }).shift();
  };

  FixturesTime.prototype.formatDate = function(d) {
    return d.toUTCString().match(/, (\w+ \w+ \w+)/)[1];
  };

  FixturesTime.prototype.formatTime = function(d) {
    return d.toUTCString().match(/(\d+:\d+):/)[1];
  };

  FixturesTime.prototype.ceil = function(time, unit) {
    var nearFuture, rounded;
    if (unit.name === "year") {
      nearFuture = new Date((time + unit.seconds - 1) * 1000);
      rounded = new Date(0);
      rounded.setUTCFullYear(nearFuture.getUTCFullYear());
      rounded.setUTCMonth(0);
      rounded.setUTCDate(1);
      rounded.setUTCHours(0);
      rounded.setUTCMinutes(0);
      rounded.setUTCSeconds(0);
      rounded.setUTCMilliseconds(0);
      return rounded.getTime() / 1000;
    }
    return Math.ceil(time / unit.seconds) * unit.seconds;
  };

  return FixturesTime;

})();

var AxisY;

Tactile.AxisY = AxisY = (function() {

  function AxisY(options) {
    var pixelsPerTick,
      _this = this;
    this.options = options;
    this.graph = options.graph;
    this.orientation = options.orientation || "left";
    pixelsPerTick = options.pixelsPerTick || 75;
    this.ticks = options.ticks || Math.floor(this.graph.height() / pixelsPerTick);
    this.tickSize = options.tickSize || 4;
    this.ticksTreatment = options.ticksTreatment || "plain";
    this.grid = options.grid;
    this.graph.onUpdate(function() {
      return _this.render();
    });
  }

  AxisY.prototype.render = function() {
    var axis, grid, gridSize, y, yAxis;
    if (this.graph.y == null) {
      return;
    }
    y = this.graph.vis.selectAll('.y-ticks').data([0]);
    y.enter().append("g").attr("class", ["y-ticks", this.ticksTreatment].join(" "));
    axis = d3.svg.axis().scale(this.graph.y).orient(this.orientation);
    axis.tickFormat(this.options.tickFormat || function(y) {
      return y;
    });
    yAxis = axis.ticks(this.ticks).tickSubdivide(0).tickSize(this.tickSize);
    y.transition().duration(this.graph.transitionSpeed).call(yAxis);
    if (this.grid) {
      console.log("grid");
      gridSize = (this.orientation === "right" ? 1 : -1) * this.graph.width();
      grid = this.graph.vis.selectAll('.y-grid').data([0]);
      grid.enter().append("svg:g").attr("class", "y-grid");
      grid.transition().call(axis.ticks(this.ticks).tickSubdivide(0).tickSize(gridSize));
    }
    return this._renderHeight = this.graph.height();
  };

  return AxisY;

})();

var Dragger,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Tactile.Dragger = Dragger = (function() {

  function Dragger(args) {
    this.update = __bind(this.update, this);

    this._mouseUp = __bind(this._mouseUp, this);

    this._mouseMove = __bind(this._mouseMove, this);

    this._datapointDrag = __bind(this._datapointDrag, this);
    this.renderer = args.renderer;
    this.graph = this.renderer.graph;
    this.series = this.renderer.series;
    this.drawCircles = args.circles || false;
    this.afterDrag = this.series.afterDrag || function() {};
    this.onDrag = this.series.onDrag || function() {};
    this.dragged = null;
    this._bindMouseEvents();
    this.power = this.series.sigfigs != null ? Math.pow(10, this.series.sigfigs) : 1;
    this.setSpeed = this.renderer.transitionSpeed;
    this.timesRendered = 0;
  }

  Dragger.prototype._bindMouseEvents = function() {
    return d3.select(this.graph._element).on("mousemove.drag." + this.series.name, this._mouseMove).on("touchmove.drag." + this.series.name, this._mouseMove).on("mouseup.drag." + this.series.name, this._mouseUp).on("touchend.drag." + this.series.name, this._mouseUp);
  };

  Dragger.prototype.makeHandlers = function(nodes) {
    if (this.drawCircles) {
      nodes = this._appendCircles(nodes);
    }
    return nodes.on("mousedown.drag." + this.series.name, this._datapointDrag).on("touchstart.drag." + this.series.name, this._datapointDrag);
  };

  Dragger.prototype.updateDraggedNode = function() {
    var _ref,
      _this = this;
    if (((_ref = this.dragged) != null ? _ref.y : void 0) != null) {
      return this.renderer.seriesCanvas().selectAll('.draggable-node').filter(function(d, i) {
        return i === _this.dragged.i;
      }).each(function(d) {
        d.y = _this.dragged.y;
        return d.dragged = true;
      });
    }
  };

  Dragger.prototype._datapointDrag = function(d, i) {
    d = _.isArray(d) ? d[i] : d;
    if (this.series.tooltip) {
      Tactile.Tooltip.spotlightOn(d);
    }
    this.dragged = {
      d: d,
      i: i
    };
    return this.update();
  };

  Dragger.prototype._mouseMove = function() {
    var elementRelativeposition, inverted, offsetTop, p, t, tip, value;
    p = d3.svg.mouse(this.graph.vis.node());
    t = d3.event.changedTouches;
    if (this.dragged) {
      if (this.series.tooltip) {
        elementRelativeposition = d3.mouse(this.graph._element);
        tip = d3.select(this.graph._element).select('.tooltip');
        offsetTop = this.graph.padding.top + this.graph.margin.top;
        tip.style("top", "" + (this.graph.y(this.dragged.y) + offsetTop) + "px");
      }
      this.renderer.transitionSpeed = 0;
      inverted = this.graph.y.invert(Math.max(0, Math.min(this.graph.height(), p[1])));
      value = Math.round(inverted * this.power) / this.power;
      this.dragged.y = value;
      this.onDrag(this.dragged, this.series, this.graph);
      return this.update();
    }
  };

  Dragger.prototype._mouseUp = function() {
    var _ref,
      _this = this;
    if (((_ref = this.dragged) != null ? _ref.y : void 0) == null) {
      return;
    }
    if (this.dragged) {
      this.afterDrag(this.dragged.d, this.dragged.y, this.dragged.i, this.series, this.graph);
    }
    this.renderer.seriesCanvas().selectAll('circle.draggable-node').data(this.series.stack).attr("class", function(d) {
      d.dragged = false;
      return "draggable-node";
    });
    d3.select("body").style("cursor", "auto");
    this.dragged = null;
    if (this.series.tooltip) {
      Tactile.Tooltip.turnOffspotlight();
    }
    this.renderer.transitionSpeed = this.setSpeed;
    return this.update();
  };

  Dragger.prototype.update = function() {
    return this.renderer.render();
  };

  Dragger.prototype._appendCircles = function(nodes) {
    var circs, renderer,
      _this = this;
    renderer = this.renderer;
    circs = this.renderer.seriesCanvas().selectAll('circle.draggable-node').data(this.series.stack);
    circs.enter().append("svg:circle").style('display', 'none');
    circs.attr("r", 4).attr("clip-path", "url(#scatter-clip)").attr("class", function(d) {
      return ["draggable-node", (d.dragged ? "active" : void 0)].join(' ');
    }).attr("fill", function(d) {
      if (d.dragged) {
        return 'white';
      } else {
        return _this.series.color;
      }
    }).attr("stroke", function(d) {
      if (d.dragged) {
        return _this.series.color;
      } else {
        return 'white';
      }
    }).attr("stroke-width", '2').attr('id', function(d, i) {
      return "draggable-node-" + i + "-" + d.x;
    }).style("cursor", "ns-resize");
    circs.transition().duration(this.timesRendered++ === 0 ? 0 : this.renderer.transitionSpeed).attr("cx", function(d) {
      return _this.graph.x(d.x);
    }).attr("cy", function(d) {
      return _this.graph.y(d.y);
    });
    nodes.on('mouseover.show-dragging-circle', function(d, i, el) {
      var circ;
      renderer.seriesCanvas().selectAll('.draggable-node').style('display', 'none');
      circ = renderer.seriesCanvas().select("#draggable-node-" + i + "-" + d.x);
      return circ.style('display', '');
    });
    circs.tooltip(function(d, i) {
      return {
        graph: _this.graph,
        text: _this.series.tooltip(d),
        circleOnHover: true,
        gravity: "right"
      };
    });
    return renderer.seriesCanvas().selectAll('.draggable-node');
  };

  return Dragger;

})();

var AxisTime;

Tactile.AxisTime = AxisTime = (function() {

  function AxisTime(args) {
    var _this = this;
    this.graph = args.graph;
    this.ticksTreatment = args.ticksTreatment || "plain";
    this.fixedTimeUnit = args.timeUnit;
    this.marginTop = args.paddingBottom || 5;
    this.time = new FixturesTime();
    this.grid = args.grid;
    this.graph.onUpdate(function() {
      return _this.render();
    });
  }

  AxisTime.prototype.appropriateTimeUnit = function() {
    var domain, rangeSeconds, unit, units;
    unit = void 0;
    units = this.time.units;
    domain = this.graph.x.domain();
    rangeSeconds = domain[1] - domain[0];
    units.forEach(function(u) {
      if (Math.floor(rangeSeconds / u.seconds) >= 2) {
        return unit = unit || u;
      }
    });
    return unit || this.time.units[this.time.units.length - 1];
  };

  AxisTime.prototype.tickOffsets = function() {
    var count, domain, i, offsets, runningTick, tickValue, unit;
    domain = this.graph.x.domain();
    unit = this.fixedTimeUnit || this.appropriateTimeUnit();
    count = Math.ceil((domain[1] - domain[0]) / unit.seconds);
    runningTick = domain[0];
    offsets = [];
    i = 0;
    while (i <= count) {
      tickValue = this.time.ceil(runningTick, unit);
      runningTick = tickValue + unit.seconds / 2;
      offsets.push({
        value: tickValue,
        unit: unit
      });
      i++;
    }
    return offsets;
  };

  AxisTime.prototype.render = function() {
    var g, tickData, ticks,
      _this = this;
    if (this.graph.x == null) {
      return;
    }
    g = this.graph.vis.selectAll('.x-ticks').data([0]);
    g.enter().append('g').attr('class', 'x-ticks');
    tickData = this.tickOffsets().filter(function(tick) {
      var _ref;
      return (_this.graph.x.range()[0] <= (_ref = _this.graph.x(tick.value)) && _ref <= _this.graph.x.range()[1]);
    });
    ticks = g.selectAll('g.x-tick').data(this.tickOffsets(), function(d) {
      return d.value;
    });
    ticks.enter().append('g').attr("class", ["x-tick", this.ticksTreatment].join(' ')).attr("transform", function(d) {
      return "translate(" + (_this.graph.x(d.value)) + ", " + _this.graph.marginedHeight + ")";
    }).append('text').attr("y", this.marginTop).text(function(d) {
      return d.unit.formatter(new Date(d.value * 1000));
    }).attr("class", 'title');
    ticks.attr("transform", function(d) {
      return "translate(" + (_this.graph.x(d.value)) + ", " + _this.graph.marginedHeight + ")";
    });
    return ticks.exit().remove();
  };

  return AxisTime;

})();

var RendererBase,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Tactile.RendererBase = RendererBase = (function() {

  RendererBase.prototype.defaults = {
    cartesian: true,
    tension: 0.95,
    strokeWidth: 3,
    unstack: true,
    dotSize: 5,
    opacity: 1,
    stroke: false,
    fill: false
  };

  function RendererBase(options) {
    if (options == null) {
      options = {};
    }
    this.render = __bind(this.render, this);

    this.graph = options.graph;
    this.tension = options.tension || this.tension;
    this.configure(options);
    if (typeof this.initialize === "function") {
      this.initialize(options);
    }
  }

  RendererBase.prototype.seriesPathFactory = function() {};

  RendererBase.prototype.seriesStrokeFactory = function() {};

  RendererBase.prototype.domain = function() {
    var stackedData, topSeriesData, values, xMax, xMin, yMax, yMin,
      _this = this;
    values = [];
    stackedData = this.graph.stackedData || this.graph.stackData();
    topSeriesData = (this.unstack ? stackedData : [stackedData.slice(-1).shift()]);
    topSeriesData.forEach(function(series) {
      return series.forEach(function(d) {
        if (_this.unstack) {
          return values.push(d.y);
        } else {
          return values.push(d.y + d.y0);
        }
      });
    });
    xMin = stackedData[0][0].x;
    xMax = stackedData[0][stackedData[0].length - 1].x;
    yMin = (this.graph.min === "auto" ? d3.min(values) : this.graph.min || 0);
    yMax = this.graph.max || d3.max(values);
    return {
      x: [xMin, xMax],
      y: [yMin, yMax]
    };
  };

  RendererBase.prototype.render = function() {
    var line;
    if (this.series.disabled) {
      this.timesRendered = 0;
      line = this.seriesCanvas().selectAll("path").data([this.series.stack]).remove();
      return;
    }
    line = this.seriesCanvas().selectAll("path").data([this.series.stack]);
    line.enter().append("svg:path").attr("clip-path", "url(#clip)").attr("fill", (this.fill ? this.series.color : "none")).attr("stroke", (this.stroke ? this.series.color : "none")).attr("stroke-width", this.strokeWidth).style('opacity', this.opacity).attr("class", "" + (this.series.className || '') + " " + (this.series.color ? '' : 'colorless'));
    return line.transition().duration(this.transitionSpeed).attr("d", this.seriesPathFactory());
  };

  RendererBase.prototype.seriesCanvas = function() {
    this._seriesCanvas || (this._seriesCanvas = this.graph.vis.selectAll("g#" + (this._nameToId())).data([this.series.stack]).enter().append("g").attr('id', this._nameToId()).attr('class', this.name));
    return this._seriesCanvas;
  };

  RendererBase.prototype.configure = function(options) {
    var defaults,
      _this = this;
    if (this.specificDefaults != null) {
      defaults = _.extend({}, this.defaults, this.specificDefaults);
    }
    options = _.extend({}, defaults, options);
    return _.each(options, function(val, key) {
      return _this[key] = val;
    });
  };

  RendererBase.prototype._nameToId = function() {
    var _ref;
    return (_ref = this.series.name) != null ? _ref.replace(/\s+/g, '-').toLowerCase() : void 0;
  };

  return RendererBase;

})();

var GaugeRenderer,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Tactile.GaugeRenderer = GaugeRenderer = (function(_super) {

  __extends(GaugeRenderer, _super);

  function GaugeRenderer() {
    return GaugeRenderer.__super__.constructor.apply(this, arguments);
  }

  GaugeRenderer.prototype.name = "gauge";

  GaugeRenderer.prototype.specificDefaults = {
    cartesian: false
  };

  GaugeRenderer.prototype.render = function() {
    var angleRange, arcs, arcsInner, innerArc, lineData, maxAngle, minAngle, originTranslate, outerArc, pg, plotAngle, plotValue, pointer, pointerHeadLength, pointerLine, pointerTailLength, pointerWidth, r, ringInset, ringWidth, scale, totalSizeDivide, translateHeight, translateWidth;
    scale = d3.scale.linear().range([0, 1]).domain(this.domain());
    ringInset = 0.300;
    ringWidth = 0.750;
    pointerWidth = 0.100;
    pointerTailLength = 0.015;
    pointerHeadLength = 0.900;
    totalSizeDivide = 1.3;
    this.bottomOffset = 0.75;
    minAngle = -85;
    maxAngle = 85;
    angleRange = maxAngle - minAngle;
    plotValue = this.value;
    r = Math.round(this.graph.height() / totalSizeDivide);
    translateWidth = (this.graph.width()) / 2;
    translateHeight = r;
    originTranslate = "translate(" + translateWidth + ", " + translateHeight + ")";
    outerArc = d3.svg.arc().outerRadius(r * ringWidth).innerRadius(r * ringInset).startAngle(this.graph._deg2rad(minAngle)).endAngle(this.graph._deg2rad(minAngle + angleRange));
    arcs = this.graph.vis.append("g").attr("class", "gauge arc").attr("transform", originTranslate);
    arcs.selectAll("path").data([1]).enter().append("path").attr("d", outerArc);
    plotAngle = minAngle + (scale(plotValue) * angleRange);
    innerArc = d3.svg.arc().outerRadius(r * ringWidth).innerRadius(r * ringInset).startAngle(this.graph._deg2rad(minAngle)).endAngle(this.graph._deg2rad(plotAngle));
    arcsInner = this.graph.vis.append("g").attr("class", "gauge arc-value").attr("transform", originTranslate);
    arcsInner.selectAll("path").data([1]).enter().append("path").attr("d", innerArc);
    lineData = [[r * pointerWidth / 2, 0], [0, -(r * pointerHeadLength)], [-(r * pointerWidth / 2), 0], [0, r * pointerTailLength], [r * pointerWidth / 2, 0]];
    pointerLine = d3.svg.line().interpolate("monotone");
    pg = this.graph.vis.append("g").data([lineData]).attr("class", "gauge pointer").attr("transform", originTranslate);
    pointer = pg.append("path").attr("d", pointerLine);
    pointer.transition().duration(250).attr("transform", "rotate(" + plotAngle + ")");
    this.graph.vis.append("svg:circle").attr("r", this.graph.width() / 30).attr("class", "gauge pointer-circle").style("opacity", 1).attr("transform", originTranslate);
    this.graph.vis.append("svg:circle").attr("r", this.graph.width() / 90).attr('class', 'gauge pointer-nail').style("opacity", 1).attr('transform', originTranslate);
    if (this.series.labels) {
      return this.renderLabels();
    }
  };

  GaugeRenderer.prototype.renderLabels = function() {
    this.graph.vis.append("text").attr("class", "gauge label").text(this.min).attr("transform", "translate(" + (0.1 * this.graph.width()) + ", " + (1.15 * this.graph.height() * this.bottomOffset) + ")");
    this.graph.vis.append("text").attr("class", "gauge label").text(this.value).attr("transform", "translate(" + ((this.graph.width() - this.graph.margin.right) / 1.95) + ", " + (1.20 * this.graph.height() * this.bottomOffset) + ")");
    return this.graph.vis.append("text").attr("class", "gauge label").text(this.max).attr("transform", "translate(" + (0.90 * this.graph.width()) + ", " + (1.15 * this.graph.height() * this.bottomOffset) + ")");
  };

  GaugeRenderer.prototype.domain = function() {
    this.value = this.series.stack[0].value;
    this.min = this.series.stack[0].min;
    this.max = this.series.stack[0].max;
    return [this.min, this.max];
  };

  return GaugeRenderer;

})(RendererBase);

var ColumnRenderer,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Tactile.ColumnRenderer = ColumnRenderer = (function(_super) {

  __extends(ColumnRenderer, _super);

  function ColumnRenderer() {
    this._barY = __bind(this._barY, this);

    this._barX = __bind(this._barX, this);

    this._seriesBarWidth = __bind(this._seriesBarWidth, this);

    this._edgeRatio = __bind(this._edgeRatio, this);

    this._transformMatrix = __bind(this._transformMatrix, this);
    return ColumnRenderer.__super__.constructor.apply(this, arguments);
  }

  ColumnRenderer.prototype.name = "column";

  ColumnRenderer.prototype.specificDefaults = {
    gapSize: 0.15,
    tension: null,
    round: true,
    unstack: true
  };

  ColumnRenderer.prototype.initialize = function(options) {
    if (options == null) {
      options = {};
    }
    if (this.series.draggable) {
      this.dragger = new Dragger({
        renderer: this,
        circles: true
      });
    }
    this.gapSize = options.gapSize || this.gapSize;
    return this.timesRendered = 0;
  };

  ColumnRenderer.prototype.render = function() {
    var nodes, _ref, _ref1,
      _this = this;
    if (this.series.disabled) {
      this.timesRendered = 0;
      this.dragger.timesRendered = 0;
      this.seriesCanvas().selectAll("rect").data(this.series.stack).remove();
      this.seriesCanvas().selectAll('circle').data(this.series.stack).remove();
      return;
    }
    nodes = this.seriesCanvas().selectAll("rect").data(this.series.stack);
    nodes.enter().append("svg:rect").attr("clip-path", "url(#clip)");
    if ((_ref = this.dragger) != null) {
      _ref.makeHandlers(nodes);
    }
    if ((_ref1 = this.dragger) != null) {
      _ref1.updateDraggedNode();
    }
    nodes.transition().duration(this.timesRendered++ === 0 ? 0 : this.transitionSpeed).attr("x", this._barX).attr("y", this._barY).attr("width", this._seriesBarWidth()).attr("height", function(d) {
      return _this.graph.y.magnitude(Math.abs(d.y));
    }).attr("transform", this._transformMatrix).attr("fill", this.series.color).attr("stroke", 'white').attr("rx", this._edgeRatio).attr("ry", this._edgeRatio).attr("class", function(d) {
      return ["bar", (!_this.series.color ? "colorless" : void 0)].join(' ');
    });
    return this.setupTooltips();
  };

  ColumnRenderer.prototype.setupTooltips = function() {
    var _this = this;
    if (this.series.tooltip) {
      return this.seriesCanvas().selectAll("rect").tooltip(function(d, i) {
        return {
          circleColor: _this.series.color,
          graph: _this.graph,
          text: _this.series.tooltip(d),
          circleOnHover: (_this.series.draggable ? false : true),
          tooltipCircleContainer: _this.graph.vis.node(),
          gravity: "right"
        };
      });
    }
  };

  ColumnRenderer.prototype.barWidth = function() {
    var barWidth, count, data;
    data = this.series.stack;
    count = data.length;
    return barWidth = this.graph.width() / count * (1 - this.gapSize);
  };

  ColumnRenderer.prototype.stackTransition = function() {
    var count, nodes, slideTransition,
      _this = this;
    this.unstack = false;
    this.graph.discoverRange(this);
    count = this.series.stack.length;
    nodes = this.seriesCanvas().selectAll("rect").data(this.series.stack);
    nodes.enter().append("svg:rect");
    slideTransition = function() {
      return _this.seriesCanvas().selectAll("rect").transition().duration(_this.timesRendered++ === 0 ? 0 : _this.transitionSpeed).attr("width", _this._seriesBarWidth()).attr("x", _this._barX);
    };
    this.seriesCanvas().selectAll("rect").transition().duration(this.timesRendered++ === 0 ? 0 : this.transitionSpeed).attr("y", this._barY).attr("height", function(d) {
      return _this.graph.y.magnitude(Math.abs(d.y));
    }).each('end', slideTransition);
    this.setupTooltips();
    return this.graph.updateCallbacks.forEach(function(callback) {
      return callback();
    });
  };

  ColumnRenderer.prototype.unstackTransition = function() {
    var count, growTransition,
      _this = this;
    this.unstack = true;
    this.graph.discoverRange(this);
    count = this.series.stack.length;
    growTransition = function() {
      return _this.seriesCanvas().selectAll("rect").transition().duration(_this.timesRendered++ === 0 ? 0 : _this.transitionSpeed).attr("height", function(d) {
        return _this.graph.y.magnitude(Math.abs(d.y));
      }).attr("y", _this._barY);
    };
    this.seriesCanvas().selectAll("rect").transition().duration(this.timesRendered++ === 0 ? 0 : this.transitionSpeed).attr("x", this._barX).attr("width", this._seriesBarWidth()).each('end', growTransition);
    this.setupTooltips();
    return this.graph.updateCallbacks.forEach(function(callback) {
      return callback();
    });
  };

  ColumnRenderer.prototype._transformMatrix = function(d) {
    var matrix;
    matrix = [1, 0, 0, (d.y < 0 ? -1 : 1), 0, (d.y < 0 ? this.graph.y.magnitude(Math.abs(d.y)) * 2 : 0)];
    return "matrix(" + matrix.join(",") + ")";
  };

  ColumnRenderer.prototype._edgeRatio = function() {
    if (this.series.round) {
      return Math.round(0.05783 * this._seriesBarWidth() + 1);
    } else {
      return 0;
    }
  };

  ColumnRenderer.prototype._seriesBarWidth = function() {
    var width,
      _this = this;
    if (this.series.stack.length >= 2) {
      width = (this.graph.x(this.series.stack[1].x) - this.graph.x(this.series.stack[0].x)) / (1 + this.gapSize);
    } else {
      width = this.graph.width() / (1 + this.gapSize);
    }
    if (this.unstack) {
      width = width / this.graph.series.filter(function(d) {
        return d.renderer === 'column';
      }).length;
    }
    return width;
  };

  ColumnRenderer.prototype._barXOffset = function(seriesBarWidth) {
    var barXOffset, count;
    count = this.graph.renderersByType(this.name).length;
    if (count === 1 || !this.unstack) {
      return barXOffset = -seriesBarWidth / 2;
    } else {
      return barXOffset = -seriesBarWidth * count / 2;
    }
  };

  ColumnRenderer.prototype._barX = function(d) {
    var initialX, seriesBarWidth, x;
    x = this.graph.x(d.x);
    seriesBarWidth = this._seriesBarWidth();
    initialX = x + this._barXOffset(seriesBarWidth);
    if (this.unstack) {
      return initialX + (this._columnRendererIndex() * seriesBarWidth);
    } else {
      return initialX;
    }
  };

  ColumnRenderer.prototype._barY = function(d) {
    if (this.unstack) {
      return this.graph.y(Math.abs(d.y)) * (d.y < 0 ? -1 : 1);
    } else {
      return this.graph.y(d.y0 + Math.abs(d.y)) * (d.y < 0 ? -1 : 1);
    }
  };

  ColumnRenderer.prototype._columnRendererIndex = function() {
    var renderers,
      _this = this;
    if (this.rendererIndex === 0 || this.rendererIndex === void 0) {
      return 0;
    }
    renderers = this.graph.renderers.slice(0, this.rendererIndex);
    return _.filter(renderers, function(r) {
      return r.name === _this.name;
    }).length;
  };

  return ColumnRenderer;

})(RendererBase);

var LineRenderer,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Tactile.LineRenderer = LineRenderer = (function(_super) {

  __extends(LineRenderer, _super);

  function LineRenderer() {
    this.render = __bind(this.render, this);
    return LineRenderer.__super__.constructor.apply(this, arguments);
  }

  LineRenderer.prototype.name = "line";

  LineRenderer.prototype.specificDefaults = {
    unstack: true,
    fill: false,
    stroke: true,
    dotSize: 5
  };

  LineRenderer.prototype.seriesPathFactory = function() {
    var _this = this;
    return d3.svg.line().x(function(d) {
      return _this.graph.x(d.x);
    }).y(function(d) {
      return _this.graph.y(d.y);
    }).interpolate(this.graph.interpolation).tension(this.tension);
  };

  LineRenderer.prototype.initialize = function() {
    if (this.series.draggable) {
      this.dragger = new Dragger({
        renderer: this
      });
    }
    return this.timesRendered = 0;
  };

  LineRenderer.prototype.render = function() {
    var circ, newCircs, _ref, _ref1,
      _this = this;
    LineRenderer.__super__.render.call(this);
    if (this.series.disabled) {
      this.seriesCanvas().selectAll('circle').data(this.series.stack).remove();
      return;
    }
    circ = this.seriesCanvas().selectAll('circle').data(this.series.stack);
    newCircs = circ.enter().append("svg:circle");
    if ((_ref = this.dragger) != null) {
      _ref.makeHandlers(newCircs);
    }
    if ((_ref1 = this.dragger) != null) {
      _ref1.updateDraggedNode();
    }
    circ.transition().duration(this.timesRendered++ === 0 ? 0 : this.transitionSpeed).attr("cx", function(d) {
      return _this.graph.x(d.x);
    }).attr("cy", function(d) {
      return _this.graph.y(d.y);
    }).attr("r", function(d) {
      if ("r" in d) {
        return d.r;
      } else {
        if (d.dragged) {
          return _this.dotSize + 1;
        } else {
          return _this.dotSize;
        }
      }
    }).attr("clip-path", "url(#scatter-clip)").attr("class", function(d) {
      return [(_this.dragger ? "draggable-node" : void 0), (d.dragged ? "active" : void 0)].join(' ');
    }).attr("fill", function(d) {
      if (d.dragged) {
        return 'white';
      } else {
        return _this.series.color;
      }
    }).attr("stroke", function(d) {
      if (d.dragged) {
        return _this.series.color;
      } else {
        return 'white';
      }
    }).attr("stroke-width", '2');
    if (this.series.draggable) {
      circ.style("cursor", "ns-resize");
    }
    circ.exit().remove();
    if (this.series.tooltip) {
      return circ.tooltip(function(d, i) {
        return {
          circleColor: _this.series.color,
          graph: _this.graph,
          text: _this.series.tooltip(d),
          circleOnHover: true,
          tooltipCircleContainer: _this.graph.vis.node(),
          gravity: "right"
        };
      });
    }
  };

  return LineRenderer;

})(RendererBase);

var AreaRenderer,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Tactile.AreaRenderer = AreaRenderer = (function(_super) {

  __extends(AreaRenderer, _super);

  function AreaRenderer() {
    this._y0 = __bind(this._y0, this);
    return AreaRenderer.__super__.constructor.apply(this, arguments);
  }

  AreaRenderer.prototype.name = "area";

  AreaRenderer.prototype.dotSize = 5;

  AreaRenderer.prototype.specificDefaults = {
    unstack: true,
    fill: true,
    stroke: true,
    opacity: 0.15
  };

  AreaRenderer.prototype._y0 = function(d) {
    if (this.unstack) {
      return 0;
    } else {
      return d.y0;
    }
  };

  AreaRenderer.prototype.initialize = function() {
    if (this.series.draggable) {
      this.dragger = new Dragger({
        renderer: this
      });
    }
    return this.timesRendered = 0;
  };

  AreaRenderer.prototype.seriesPathFactory = function() {
    var _this = this;
    return d3.svg.area().x(function(d) {
      return _this.graph.x(d.x);
    }).y0(function(d) {
      return _this.graph.y(_this._y0(d));
    }).y1(function(d) {
      return _this.graph.y(d.y + _this._y0(d));
    }).interpolate(this.graph.interpolation).tension(this.tension);
  };

  AreaRenderer.prototype.seriesStrokeFactory = function() {
    var _this = this;
    return d3.svg.line().x(function(d) {
      return _this.graph.x(d.x);
    }).y(function(d) {
      return _this.graph.y(d.y + _this._y0(d));
    }).interpolate(this.graph.interpolation).tension(this.tension);
  };

  AreaRenderer.prototype.render = function() {
    var circ, newCircs, stroke, _ref, _ref1,
      _this = this;
    AreaRenderer.__super__.render.call(this);
    if (this.series.disabled) {
      this.timesRendered = 0;
      this.seriesCanvas().selectAll("path").remove();
      this.seriesCanvas().selectAll('circle').remove();
      return;
    }
    stroke = this.seriesCanvas().selectAll('path.stroke').data([this.series.stack]);
    stroke.enter().append("svg:path").attr("clip-path", "url(#clip)").attr('fill', 'none').attr("stroke-width", '2').attr("stroke", this.series.color).attr('class', 'stroke');
    stroke.transition().duration(this.transitionSpeed).attr("d", this.seriesStrokeFactory());
    circ = this.seriesCanvas().selectAll('circle').data(this.series.stack);
    newCircs = circ.enter().append("svg:circle");
    if ((_ref = this.dragger) != null) {
      _ref.makeHandlers(newCircs);
    }
    if ((_ref1 = this.dragger) != null) {
      _ref1.updateDraggedNode(circ);
    }
    circ.transition().duration(this.timesRendered++ === 0 ? 0 : this.transitionSpeed).attr("cx", function(d) {
      return _this.graph.x(d.x);
    }).attr("cy", function(d) {
      return _this.graph.y(d.y);
    }).attr("r", function(d) {
      if ("r" in d) {
        return d.r;
      } else {
        if (d.dragged) {
          return _this.dotSize + 1;
        } else {
          return _this.dotSize;
        }
      }
    }).attr("clip-path", "url(#scatter-clip)").attr("class", function(d) {
      return [(_this.series.draggable ? "draggable-node" : void 0), (d.dragged ? "active" : null)].join(' ');
    }).attr("fill", function(d) {
      if (d.dragged) {
        return 'white';
      } else {
        return _this.series.color;
      }
    }).attr("stroke", function(d) {
      if (d.dragged) {
        return _this.series.color;
      } else {
        return 'white';
      }
    }).attr("stroke-width", '2');
    if (this.series.draggable) {
      circ.style("cursor", "ns-resize");
    }
    return circ.exit().remove();
  };

  return AreaRenderer;

})(RendererBase);

var ScatterRenderer,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Tactile.ScatterRenderer = ScatterRenderer = (function(_super) {

  __extends(ScatterRenderer, _super);

  function ScatterRenderer() {
    return ScatterRenderer.__super__.constructor.apply(this, arguments);
  }

  ScatterRenderer.prototype.name = "scatter";

  ScatterRenderer.prototype.specificDefaults = {
    fill: true,
    stroke: false
  };

  ScatterRenderer.prototype.render = function() {
    var circ,
      _this = this;
    circ = this.seriesCanvas().selectAll('circle').data(this.series.stack);
    circ.enter().append("svg:circle").attr("cx", function(d) {
      return _this.graph.x(d.x);
    }).attr("cy", function(d) {
      return _this.graph.y(d.y);
    });
    circ.transition().duration(this.transitionSpeed).attr("cx", function(d) {
      return _this.graph.x(d.x);
    }).attr("cy", function(d) {
      return _this.graph.y(d.y);
    }).attr("r", function(d) {
      if ("r" in d) {
        return d.r;
      } else {
        return _this.dotSize;
      }
    }).attr("fill", this.series.color).attr("stroke", 'white').attr("stroke-width", '2');
    if (this.series.cssConditions) {
      circ.attr('class', function(d) {
        return _this.series.cssConditions(d);
      });
    }
    if (this.series.tooltip) {
      this.seriesCanvas().selectAll("circle").tooltip(function(d, i) {
        return {
          graph: _this.graph,
          text: _this.series.tooltip(d),
          mousemove: true,
          gravity: "right",
          displacement: [5, d.r - 5]
        };
      });
    }
    return circ.exit().remove();
  };

  return ScatterRenderer;

})(RendererBase);

var DonutRenderer,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Tactile.DonutRenderer = DonutRenderer = (function(_super) {

  __extends(DonutRenderer, _super);

  function DonutRenderer() {
    return DonutRenderer.__super__.constructor.apply(this, arguments);
  }

  DonutRenderer.prototype.name = "donut";

  return DonutRenderer;

})(RendererBase);

var RangeSlider,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Tactile.RangeSlider = RangeSlider = (function() {

  function RangeSlider(options) {
    this.updateGraph = __bind(this.updateGraph, this);

    var _this = this;
    this.element = options.element;
    this.graph = options.graph;
    this.timeSliderClass = options.sliderClass;
    this.updateCallback = options.updateCallback || function() {};
    this.initCallback = options.updateCallback || function() {};
    $(function() {
      var sliderContainer, values;
      values = options.values || [_this.graph.dataDomain()[0], _this.graph.dataDomain()[1]];
      _this.initCallback(values, _this.element);
      _this.updateGraph(values);
      if (_this.timeSliderClass) {
        sliderContainer = _this.element.find(_this.timeSliderClass);
      } else {
        sliderContainer = _this.element;
      }
      return sliderContainer.slider({
        range: true,
        min: _this.graph.dataDomain()[0],
        max: _this.graph.dataDomain()[1],
        values: values,
        slide: function(event, ui) {
          _this.updateGraph(ui.values);
          if (_this.graph.dataDomain()[0] === ui.values[0]) {
            _this.graph.window.xMin = void 0;
          }
          if (_this.graph.dataDomain()[1] === ui.values[1]) {
            return _this.graph.window.xMax = void 0;
          }
        }
      });
    });
    this.graph.onUpdate(function() {
      var values;
      values = $(_this.element).slider("option", "values");
      $(_this.element).slider("option", "min", _this.graph.dataDomain()[0]);
      $(_this.element).slider("option", "max", _this.graph.dataDomain()[1]);
      if (_this.graph.window.xMin === void 0) {
        values[0] = _this.graph.dataDomain()[0];
      }
      if (_this.graph.window.xMax === void 0) {
        values[1] = _this.graph.dataDomain()[1];
      }
      return $(_this.element).slider("option", "values", values);
    });
  }

  RangeSlider.prototype.updateGraph = function(values) {
    this.graph.window.xMin = values[0];
    this.graph.window.xMax = values[1];
    this.updateCallback(values, this.element);
    return this.graph.update();
  };

  return RangeSlider;

})();

var Chart,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Tactile.Chart = Chart = (function() {

  Chart.prototype._renderers = {
    'gauge': GaugeRenderer,
    'column': ColumnRenderer,
    'line': LineRenderer,
    'area': AreaRenderer,
    'scatter': ScatterRenderer,
    'donut': DonutRenderer
  };

  Chart.prototype.margin = {
    top: 20,
    right: 20,
    bottom: 20,
    left: 20
  };

  Chart.prototype.padding = {
    top: 10,
    right: 10,
    bottom: 10,
    left: 10
  };

  Chart.prototype.interpolation = 'monotone';

  Chart.prototype.offset = 'zero';

  Chart.prototype.min = void 0;

  Chart.prototype.max = void 0;

  Chart.prototype.transitionSpeed = 200;

  Chart.prototype.defaultHeight = 400;

  Chart.prototype.defaultWidth = 730;

  Chart.prototype.defaultAxes = {
    x: {
      dimension: "time",
      frame: [void 0, void 0]
    },
    y: {
      dimension: "linear",
      frame: [void 0, void 0]
    }
  };

  function Chart(args) {
    var _this = this;
    if (args == null) {
      args = {};
    }
    this._slice = __bind(this._slice, this);

    this.discoverRange = __bind(this.discoverRange, this);

    this.renderers = [];
    this.series = [];
    this.window = {};
    this.updateCallbacks = [];
    this.setSize({
      width: args.width || this.defaultWidth,
      height: args.height || this.defaultHeight
    });
    if (args.width != null) {
      delete args.width;
    }
    if (args.height != null) {
      delete args.height;
    }
    this.axes(args.axes || this.defaultAxes);
    if (args.axes != null) {
      delete args.axes;
    }
    _.each(args, function(val, key) {
      return _this[key] = val;
    });
    this.addSeries(args.series, {
      overwrite: true
    });
  }

  Chart.prototype.addSeries = function(series, options) {
    var newSeries, seriesDefaults,
      _this = this;
    if (options == null) {
      options = {
        overwrite: false
      };
    }
    if (!series) {
      return;
    }
    if (!_.isArray(series)) {
      series = [series];
    }
    seriesDefaults = {
      dataTransform: function(d) {
        return d;
      }
    };
    newSeries = _.map(series, function(s) {
      return _.extend({}, seriesDefaults, s);
    });
    if (options.overwrite) {
      this.series = newSeries;
    } else {
      this.series = this.series.concat(newSeries);
    }
    _.each(newSeries, function(s) {
      s.disable = function() {
        return this.disabled = true;
      };
      s.enable = function() {
        return this.disabled = false;
      };
      return s.toggle = function() {
        return this.disabled = !this.disabled;
      };
    });
    this.initRenderers(newSeries);
    return this;
  };

  Chart.prototype.initSeriesStackData = function(options) {
    var i, layout, seriesData, stackedData,
      _this = this;
    if (options == null) {
      options = {
        overwrite: false
      };
    }
    if (this.dataInitialized && !options.overwrite) {
      return;
    }
    this.series.active = function() {
      return _this.series.filter(function(s) {
        return !s.disabled;
      });
    };
    seriesData = this.series.map(function(d) {
      return _this._data.map(d.dataTransform);
    });
    layout = d3.layout.stack();
    layout.offset(this.offset);
    stackedData = layout(seriesData);
    i = 0;
    this.series.forEach(function(series) {
      return series.stack = stackedData[i++];
    });
    return this.dataInitialized = true;
  };

  Chart.prototype.render = function() {
    var stackedData,
      _this = this;
    if (this.renderers === void 0 || _.isEmpty(this.renderers) || this._allSeriesDisabled()) {
      return;
    }
    this.initSeriesStackData();
    this._setupCanvas();
    stackedData = this.stackData();
    _.each(this.renderers, function(renderer) {
      _this.discoverRange(renderer);
      return renderer.render();
    });
    return this.updateCallbacks.forEach(function(callback) {
      return callback();
    });
  };

  Chart.prototype.update = function() {
    return this.render();
  };

  Chart.prototype.discoverRange = function(renderer) {
    var barWidth, domain, rangeEnd, rangeStart, xframe, yframe;
    domain = renderer.domain();
    if (renderer.cartesian) {
      if (this._containsColumnChart()) {
        barWidth = this.width() / renderer.series.stack.length / 2;
        rangeStart = barWidth;
        rangeEnd = this.width() - barWidth;
      }
      xframe = [(this._axes.x.frame[0] ? this._axes.x.frame[0] : domain.x[0]), (this._axes.x.frame[1] ? this._axes.x.frame[1] : domain.x[1])];
      yframe = [(this._axes.y.frame[0] ? this._axes.y.frame[0] : domain.y[0]), (this._axes.y.frame[1] ? this._axes.y.frame[1] : domain.y[1])];
      this.x = d3.scale.linear().domain(xframe).range([rangeStart || 0, rangeEnd || this.width()]);
      this.y = d3.scale.linear().domain(yframe).range([this.height(), 0]);
      return this.y.magnitude = d3.scale.linear().domain([domain.y[0] - domain.y[0], domain.y[1] - domain.y[0]]).range([0, this.height()]);
    }
  };

  Chart.prototype.findAxis = function(axis) {
    if (!this._allRenderersCartesian()) {
      return;
    }
    switch (axis.dimension) {
      case "linear":
        return new Tactile.AxisY(_.extend({}, axis.options, {
          graph: this
        }));
      case "time":
        return new Tactile.AxisTime(_.extend({}, axis.options, {
          graph: this
        }));
      default:
        return console.log("ERROR:" + axis.dimension + " is not currently implemented");
    }
  };

  Chart.prototype.dataDomain = function() {
    var data;
    data = this.renderers[0].series.stack;
    return [data[0].x, data.slice(-1).shift().x];
  };

  Chart.prototype.stackData = function() {
    var layout, seriesData, stackedData,
      _this = this;
    seriesData = this.series.active().map(function(d) {
      return _this._data.map(d.dataTransform);
    });
    layout = d3.layout.stack();
    layout.offset(this.offset);
    stackedData = layout(seriesData);
    return this.stackedData = stackedData;
  };

  Chart.prototype.setSize = function(args) {
    var elHeight, elWidth, _ref;
    if (args == null) {
      args = {};
    }
    elWidth = $(this._element).width();
    elHeight = $(this._element).height();
    this.outerWidth = args.width || elWidth || this.defaultWidth;
    this.outerHeight = args.height || elHeight || this.defaultHeight;
    this.marginedWidth = this.outerWidth - this.margin.left - this.margin.right;
    this.marginedHeight = this.outerHeight - this.margin.top - this.margin.bottom;
    this.innerWidth = this.marginedWidth - this.padding.left - this.padding.right;
    this.innerHeight = this.marginedHeight - this.padding.top - this.padding.bottom;
    return (_ref = this.vis) != null ? _ref.attr('width', this.innerWidth).attr('height', this.innerHeight) : void 0;
  };

  Chart.prototype.onUpdate = function(callback) {
    return this.updateCallbacks.push(callback);
  };

  Chart.prototype.initRenderers = function(series) {
    var renderersSize,
      _this = this;
    renderersSize = this.renderers.length;
    return _.each(series, function(s, index) {
      var name, r, rendererClass, rendererOptions;
      name = s.renderer;
      if (!_this._renderers[name]) {
        throw "couldn't find renderer " + name;
      }
      rendererClass = _this._renderers[name];
      rendererOptions = _.extend({}, {
        graph: _this,
        transitionSpeed: _this.transitionSpeed,
        series: s,
        rendererIndex: index + renderersSize
      });
      r = new rendererClass(rendererOptions);
      return _this.renderers.push(r);
    });
  };

  Chart.prototype.renderersByType = function(name) {
    return this.renderers.filter(function(r) {
      return r.name === name;
    });
  };

  Chart.prototype.stackTransition = function() {
    return _.each(this.renderersByType('column'), function(r) {
      return r.stackTransition();
    });
  };

  Chart.prototype.unstackTransition = function() {
    return _.each(this.renderersByType('column'), function(r) {
      return r.unstackTransition();
    });
  };

  Chart.prototype.element = function(val) {
    if (!val) {
      return this._element;
    }
    this._element = val;
    this._setupCanvas();
    return this;
  };

  Chart.prototype.height = function(val) {
    if (!val) {
      return this.innerHeight || this.defaultHeight;
    }
    this.setSize({
      width: this.outerWidth,
      height: val
    });
    return this;
  };

  Chart.prototype.width = function(val) {
    if (!val) {
      return this.innerWidth || this.defaultWidth;
    }
    this.setSize({
      width: val,
      height: this.outerHeight
    });
    return this;
  };

  Chart.prototype.data = function(val) {
    if (!val) {
      return this._data;
    }
    this._data = val;
    this.dataInitialized = false;
    return this;
  };

  Chart.prototype.axes = function(args, options) {
    var _ref, _ref1, _ref2, _ref3;
    if (!args) {
      return this._axes;
    }
    this._axes = {
      x: {
        frame: ((_ref = args.x) != null ? _ref.frame : void 0) || this.defaultAxes.x.frame,
        dimension: ((_ref1 = args.x) != null ? _ref1.dimension : void 0) || this.defaultAxes.x.dimension
      },
      y: {
        frame: ((_ref2 = args.y) != null ? _ref2.frame : void 0) || this.defaultAxes.y.frame,
        dimension: ((_ref3 = args.y) != null ? _ref3.dimension : void 0) || this.defaultAxes.y.dimension
      }
    };
    this.findAxis(this._axes.x);
    this.findAxis(this._axes.y);
    return this;
  };

  Chart.prototype._setupCanvas = function() {
    $(this._element).addClass('graph-container');
    this.svg = this._findOrAppend({
      what: 'svg',
      "in": d3.select(this._element)
    });
    this.svg.attr('width', this.outerWidth).attr('height', this.outerHeight);
    this.vis = this._findOrAppend({
      what: 'g',
      "in": this.svg
    }).attr("transform", "translate(" + this.margin.left + "," + this.margin.top + ")");
    this.vis = this._findOrAppend({
      what: 'g',
      "in": this.vis
    }).attr("class", "outer-canvas").attr("width", this.marginedWidth).attr("height", this.marginedHeight);
    this.vis = this._findOrAppend({
      what: 'g',
      "in": this.vis
    }).attr("transform", "translate(" + this.padding.left + "," + this.padding.top + ")").attr("class", "inner-canvas");
    this._findOrAppend({
      what: 'clipPath',
      selector: '#clip',
      "in": this.vis
    }).attr("id", "clip").append("rect").attr("width", this.width()).attr("height", this.height() + 4).attr("transform", "translate(0,-2)");
    return this._findOrAppend({
      what: 'clipPath',
      selector: '#scatter-clip',
      "in": this.vis
    }).attr("id", "scatter-clip").append("rect").attr("width", this.width() + 12).attr("height", this.height() + 12).attr("transform", "translate(-6,-6)");
  };

  Chart.prototype._findOrAppend = function(options) {
    var element, found, node, selector;
    element = options["in"];
    node = options.what;
    selector = options.selector || node;
    found = element.select(selector);
    if (found != null ? found[0][0] : void 0) {
      return found;
    } else {
      return element.append(node);
    }
  };

  Chart.prototype._slice = function(d) {
    var _ref;
    if (!this._allRenderersCartesian()) {
      return true;
    }
    return (this.timeframe[0] <= (_ref = d.x) && _ref <= this.timeframe[1]);
  };

  Chart.prototype._deg2rad = function(deg) {
    return deg * Math.PI / 180;
  };

  Chart.prototype._hasDifferentRenderers = function() {
    return _.uniq(_.map(this.series, function(s) {
      return s.renderer;
    })).length > 1;
  };

  Chart.prototype._containsColumnChart = function() {
    return _.any(this.renderers, function(r) {
      return r.name === 'column';
    });
  };

  Chart.prototype._allRenderersCartesian = function() {
    return _.every(this.renderers, function(r) {
      return r.cartesian === true;
    });
  };

  Chart.prototype._allSeriesDisabled = function() {
    return _.every(this.series, function(s) {
      return s.disabled === true;
    });
  };

  return Chart;

})();

})();