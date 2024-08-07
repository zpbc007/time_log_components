 (function () {
   'use strict';

   // 使用示例
   // 事件监听
   // const dispose = window.timeLineBridge.on("toolbar.bold.tapped", () => {
   //   console.log("toolbar.bold.tapped");
   // });
   // 主动调用，等待返回结果
   // window.timeLineBridge.call("page.close", {data: true}, (result) => {
   //   if (result) {
   //     console.log("close success");
   //   } else {
   //     console.log("close failed");
   //   }
   // });
   // 主动触发，返回结果
   // window.timeLineBridge.trigger("editor.content.change", { content: "xxx" });

   /**
    * 使用示例
    *
    * 事件监听 无返回值
    * const dispose = window.timeLineBridge.addEventListener("toolbar.bold.tapped", () => {
    *  console.log("toolbar.bold.tapped");
    * });
    *
    * 事件监听 有返回值
    * const dispose = window.timeLineBridge.addEventHandler("editor.fetchContent", () => {
    *  return quill.getContents();
    * })
    *
    * 主动调用 native api，等待返回结果
    * window.timeLineBridge.call("page.close", {data: true}, (result) => {
    *  if (result) {
    *    console.log("close success");
    *  } else {
    *    console.log("close failed");
    *  }
    * });
    *
    * 主动触发 web 事件，通知客户端
    * window.timeLineBridge.trigger("editor.content.change", { content: "xxx" });
    */

   const eventListeners = {};
   /**
    * 监听从 native 发过来的事件
    * @param {string} eventName
    * @param {function} handler
    * @returns
    */
   function addEventListener(eventName, handler) {
     if (!eventListeners[eventName]) {
       eventListeners[eventName] = [];
     }

     eventListeners[eventName].push(handler);

     // 调用方自己取消监听
     return () => {
       eventListeners[eventName] = eventListeners[eventName].filter(
         (item) => item != handler
       );
     };
   }

   /**
    * 向 native 发送前端事件
    * @param {*} eventName
    * @param {*} data
    */
   function triggerEvent(eventName, data) {
     callNative(eventName, data);
   }

   /**
    * 向 native 发送消息
    * @param {string} eventName
    * @param {*} data
    * @param {*} callback
    */
   function callNative(eventName, data, callback) {
     if (arguments.length == 2 && typeof data == "function") {
       callback = data;
       data = null;
     }

     _callNative(
       {
         eventName,
         data,
       },
       callback
     );
   }

   const responseCallbacks = {};
   /**
    * 调用 postMessage 发出 消息
    * @param {*} message
    * @param {*} callback
    */
   function _callNative(message, callback) {
     if (callback) {
       const callbackID = genUniqueID();
       // 添加 ID
       message.callbackID = callbackID;
       responseCallbacks[callbackID] = callback;
     }

     window.webkit.messageHandlers.timeLineBridge.postMessage(
       JSON.stringify({
         ...message,
         // 对数据序列化，如果 native 需要解析，再拿出来解析
         data: message.data ? JSON.stringify(message.data) : null,
       })
     );
   }

   /**
    * native 向前端发过来的消息
    * @param {*} message
    */
   function handleMessageFromNative(message) {
     const messageObj = JSON.parse(message);
     // 需要调用 callback
     if (messageObj.callbackID) {
       const callback = responseCallbacks[messageObj.callbackID];
       if (callback) {
         callback(messageObj.data);
       }
     } else {
       const handlers = eventListeners[messageObj.eventName];
       if (handlers && handlers.length > 0) {
         handlers.forEach((callback) => {
           callback(messageObj.data);
         });
       }
     }
   }

   const genUniqueID = (function () {
     const genId = () => `${Date.now()}${Math.random().toString(36).substring(2)}`;
     const idSet = new Set();

     return () => {
       if (idSet.size >= 500) {
         idSet.clear();
       }

       let newId = genId();
       while (idSet.has(newId)) {
         genId = genId();
       }

       idSet.add(newId);

       return newId;
     };
   })();

   const eventHandlers = {};
   function addEventHandler(eventName, handler) {
     eventHandlers[eventName] = handler;

     return () => {
       if (eventHandlers[eventName] === handler) {
         eventHandlers[eventName] = null;
       }
     };
   }

   function handleEventFromNative(message) {
     const { eventName, data } = JSON.parse(message) || {};

     if (eventName && eventHandlers[eventName]) {
       const res = eventHandlers[eventName](data || null);
       return res == null ? null : JSON.stringify(res);
     } else {
       return null;
     }
   }

   // 供外部调用
   window.timeLineBridge = {
     // 同一个 eventName 全局可以有多个
     addEventListener,
     // 同一个 eventName 全局只能有一个
     addEventHandler,
     callNative,
     triggerEvent,
     // 客户端不获取返回值
     _handleMessageFromNative: handleMessageFromNative,
     // 客户端需要获取返回值
     _handleEventFromNative: handleEventFromNative,
   };

   /** Detect free variable `global` from Node.js. */
   var freeGlobal = typeof global == 'object' && global && global.Object === Object && global;

   /** Detect free variable `self`. */
   var freeSelf = typeof self == 'object' && self && self.Object === Object && self;

   /** Used as a reference to the global object. */
   var root = freeGlobal || freeSelf || Function('return this')();

   /** Built-in value references. */
   var Symbol = root.Symbol;

   /** Used for built-in method references. */
   var objectProto$1 = Object.prototype;

   /** Used to check objects for own properties. */
   var hasOwnProperty = objectProto$1.hasOwnProperty;

   /**
    * Used to resolve the
    * [`toStringTag`](http://ecma-international.org/ecma-262/7.0/#sec-object.prototype.tostring)
    * of values.
    */
   var nativeObjectToString$1 = objectProto$1.toString;

   /** Built-in value references. */
   var symToStringTag$1 = Symbol ? Symbol.toStringTag : undefined;

   /**
    * A specialized version of `baseGetTag` which ignores `Symbol.toStringTag` values.
    *
    * @private
    * @param {*} value The value to query.
    * @returns {string} Returns the raw `toStringTag`.
    */
   function getRawTag(value) {
     var isOwn = hasOwnProperty.call(value, symToStringTag$1),
         tag = value[symToStringTag$1];

     try {
       value[symToStringTag$1] = undefined;
       var unmasked = true;
     } catch (e) {}

     var result = nativeObjectToString$1.call(value);
     if (unmasked) {
       if (isOwn) {
         value[symToStringTag$1] = tag;
       } else {
         delete value[symToStringTag$1];
       }
     }
     return result;
   }

   /** Used for built-in method references. */
   var objectProto = Object.prototype;

   /**
    * Used to resolve the
    * [`toStringTag`](http://ecma-international.org/ecma-262/7.0/#sec-object.prototype.tostring)
    * of values.
    */
   var nativeObjectToString = objectProto.toString;

   /**
    * Converts `value` to a string using `Object.prototype.toString`.
    *
    * @private
    * @param {*} value The value to convert.
    * @returns {string} Returns the converted string.
    */
   function objectToString(value) {
     return nativeObjectToString.call(value);
   }

   /** `Object#toString` result references. */
   var nullTag = '[object Null]',
       undefinedTag = '[object Undefined]';

   /** Built-in value references. */
   var symToStringTag = Symbol ? Symbol.toStringTag : undefined;

   /**
    * The base implementation of `getTag` without fallbacks for buggy environments.
    *
    * @private
    * @param {*} value The value to query.
    * @returns {string} Returns the `toStringTag`.
    */
   function baseGetTag(value) {
     if (value == null) {
       return value === undefined ? undefinedTag : nullTag;
     }
     return (symToStringTag && symToStringTag in Object(value))
       ? getRawTag(value)
       : objectToString(value);
   }

   /**
    * Checks if `value` is object-like. A value is object-like if it's not `null`
    * and has a `typeof` result of "object".
    *
    * @static
    * @memberOf _
    * @since 4.0.0
    * @category Lang
    * @param {*} value The value to check.
    * @returns {boolean} Returns `true` if `value` is object-like, else `false`.
    * @example
    *
    * _.isObjectLike({});
    * // => true
    *
    * _.isObjectLike([1, 2, 3]);
    * // => true
    *
    * _.isObjectLike(_.noop);
    * // => false
    *
    * _.isObjectLike(null);
    * // => false
    */
   function isObjectLike(value) {
     return value != null && typeof value == 'object';
   }

   /** `Object#toString` result references. */
   var symbolTag = '[object Symbol]';

   /**
    * Checks if `value` is classified as a `Symbol` primitive or object.
    *
    * @static
    * @memberOf _
    * @since 4.0.0
    * @category Lang
    * @param {*} value The value to check.
    * @returns {boolean} Returns `true` if `value` is a symbol, else `false`.
    * @example
    *
    * _.isSymbol(Symbol.iterator);
    * // => true
    *
    * _.isSymbol('abc');
    * // => false
    */
   function isSymbol(value) {
     return typeof value == 'symbol' ||
       (isObjectLike(value) && baseGetTag(value) == symbolTag);
   }

   /** Used to match a single whitespace character. */
   var reWhitespace = /\s/;

   /**
    * Used by `_.trim` and `_.trimEnd` to get the index of the last non-whitespace
    * character of `string`.
    *
    * @private
    * @param {string} string The string to inspect.
    * @returns {number} Returns the index of the last non-whitespace character.
    */
   function trimmedEndIndex(string) {
     var index = string.length;

     while (index-- && reWhitespace.test(string.charAt(index))) {}
     return index;
   }

   /** Used to match leading whitespace. */
   var reTrimStart = /^\s+/;

   /**
    * The base implementation of `_.trim`.
    *
    * @private
    * @param {string} string The string to trim.
    * @returns {string} Returns the trimmed string.
    */
   function baseTrim(string) {
     return string
       ? string.slice(0, trimmedEndIndex(string) + 1).replace(reTrimStart, '')
       : string;
   }

   /**
    * Checks if `value` is the
    * [language type](http://www.ecma-international.org/ecma-262/7.0/#sec-ecmascript-language-types)
    * of `Object`. (e.g. arrays, functions, objects, regexes, `new Number(0)`, and `new String('')`)
    *
    * @static
    * @memberOf _
    * @since 0.1.0
    * @category Lang
    * @param {*} value The value to check.
    * @returns {boolean} Returns `true` if `value` is an object, else `false`.
    * @example
    *
    * _.isObject({});
    * // => true
    *
    * _.isObject([1, 2, 3]);
    * // => true
    *
    * _.isObject(_.noop);
    * // => true
    *
    * _.isObject(null);
    * // => false
    */
   function isObject(value) {
     var type = typeof value;
     return value != null && (type == 'object' || type == 'function');
   }

   /** Used as references for various `Number` constants. */
   var NAN = 0 / 0;

   /** Used to detect bad signed hexadecimal string values. */
   var reIsBadHex = /^[-+]0x[0-9a-f]+$/i;

   /** Used to detect binary string values. */
   var reIsBinary = /^0b[01]+$/i;

   /** Used to detect octal string values. */
   var reIsOctal = /^0o[0-7]+$/i;

   /** Built-in method references without a dependency on `root`. */
   var freeParseInt = parseInt;

   /**
    * Converts `value` to a number.
    *
    * @static
    * @memberOf _
    * @since 4.0.0
    * @category Lang
    * @param {*} value The value to process.
    * @returns {number} Returns the number.
    * @example
    *
    * _.toNumber(3.2);
    * // => 3.2
    *
    * _.toNumber(Number.MIN_VALUE);
    * // => 5e-324
    *
    * _.toNumber(Infinity);
    * // => Infinity
    *
    * _.toNumber('3.2');
    * // => 3.2
    */
   function toNumber(value) {
     if (typeof value == 'number') {
       return value;
     }
     if (isSymbol(value)) {
       return NAN;
     }
     if (isObject(value)) {
       var other = typeof value.valueOf == 'function' ? value.valueOf() : value;
       value = isObject(other) ? (other + '') : other;
     }
     if (typeof value != 'string') {
       return value === 0 ? value : +value;
     }
     value = baseTrim(value);
     var isBinary = reIsBinary.test(value);
     return (isBinary || reIsOctal.test(value))
       ? freeParseInt(value.slice(2), isBinary ? 2 : 8)
       : (reIsBadHex.test(value) ? NAN : +value);
   }

   /**
    * Gets the timestamp of the number of milliseconds that have elapsed since
    * the Unix epoch (1 January 1970 00:00:00 UTC).
    *
    * @static
    * @memberOf _
    * @since 2.4.0
    * @category Date
    * @returns {number} Returns the timestamp.
    * @example
    *
    * _.defer(function(stamp) {
    *   console.log(_.now() - stamp);
    * }, _.now());
    * // => Logs the number of milliseconds it took for the deferred invocation.
    */
   var now = function() {
     return root.Date.now();
   };

   /** Error message constants. */
   var FUNC_ERROR_TEXT$1 = 'Expected a function';

   /* Built-in method references for those with the same name as other `lodash` methods. */
   var nativeMax = Math.max,
       nativeMin = Math.min;

   /**
    * Creates a debounced function that delays invoking `func` until after `wait`
    * milliseconds have elapsed since the last time the debounced function was
    * invoked. The debounced function comes with a `cancel` method to cancel
    * delayed `func` invocations and a `flush` method to immediately invoke them.
    * Provide `options` to indicate whether `func` should be invoked on the
    * leading and/or trailing edge of the `wait` timeout. The `func` is invoked
    * with the last arguments provided to the debounced function. Subsequent
    * calls to the debounced function return the result of the last `func`
    * invocation.
    *
    * **Note:** If `leading` and `trailing` options are `true`, `func` is
    * invoked on the trailing edge of the timeout only if the debounced function
    * is invoked more than once during the `wait` timeout.
    *
    * If `wait` is `0` and `leading` is `false`, `func` invocation is deferred
    * until to the next tick, similar to `setTimeout` with a timeout of `0`.
    *
    * See [David Corbacho's article](https://css-tricks.com/debouncing-throttling-explained-examples/)
    * for details over the differences between `_.debounce` and `_.throttle`.
    *
    * @static
    * @memberOf _
    * @since 0.1.0
    * @category Function
    * @param {Function} func The function to debounce.
    * @param {number} [wait=0] The number of milliseconds to delay.
    * @param {Object} [options={}] The options object.
    * @param {boolean} [options.leading=false]
    *  Specify invoking on the leading edge of the timeout.
    * @param {number} [options.maxWait]
    *  The maximum time `func` is allowed to be delayed before it's invoked.
    * @param {boolean} [options.trailing=true]
    *  Specify invoking on the trailing edge of the timeout.
    * @returns {Function} Returns the new debounced function.
    * @example
    *
    * // Avoid costly calculations while the window size is in flux.
    * jQuery(window).on('resize', _.debounce(calculateLayout, 150));
    *
    * // Invoke `sendMail` when clicked, debouncing subsequent calls.
    * jQuery(element).on('click', _.debounce(sendMail, 300, {
    *   'leading': true,
    *   'trailing': false
    * }));
    *
    * // Ensure `batchLog` is invoked once after 1 second of debounced calls.
    * var debounced = _.debounce(batchLog, 250, { 'maxWait': 1000 });
    * var source = new EventSource('/stream');
    * jQuery(source).on('message', debounced);
    *
    * // Cancel the trailing debounced invocation.
    * jQuery(window).on('popstate', debounced.cancel);
    */
   function debounce(func, wait, options) {
     var lastArgs,
         lastThis,
         maxWait,
         result,
         timerId,
         lastCallTime,
         lastInvokeTime = 0,
         leading = false,
         maxing = false,
         trailing = true;

     if (typeof func != 'function') {
       throw new TypeError(FUNC_ERROR_TEXT$1);
     }
     wait = toNumber(wait) || 0;
     if (isObject(options)) {
       leading = !!options.leading;
       maxing = 'maxWait' in options;
       maxWait = maxing ? nativeMax(toNumber(options.maxWait) || 0, wait) : maxWait;
       trailing = 'trailing' in options ? !!options.trailing : trailing;
     }

     function invokeFunc(time) {
       var args = lastArgs,
           thisArg = lastThis;

       lastArgs = lastThis = undefined;
       lastInvokeTime = time;
       result = func.apply(thisArg, args);
       return result;
     }

     function leadingEdge(time) {
       // Reset any `maxWait` timer.
       lastInvokeTime = time;
       // Start the timer for the trailing edge.
       timerId = setTimeout(timerExpired, wait);
       // Invoke the leading edge.
       return leading ? invokeFunc(time) : result;
     }

     function remainingWait(time) {
       var timeSinceLastCall = time - lastCallTime,
           timeSinceLastInvoke = time - lastInvokeTime,
           timeWaiting = wait - timeSinceLastCall;

       return maxing
         ? nativeMin(timeWaiting, maxWait - timeSinceLastInvoke)
         : timeWaiting;
     }

     function shouldInvoke(time) {
       var timeSinceLastCall = time - lastCallTime,
           timeSinceLastInvoke = time - lastInvokeTime;

       // Either this is the first call, activity has stopped and we're at the
       // trailing edge, the system time has gone backwards and we're treating
       // it as the trailing edge, or we've hit the `maxWait` limit.
       return (lastCallTime === undefined || (timeSinceLastCall >= wait) ||
         (timeSinceLastCall < 0) || (maxing && timeSinceLastInvoke >= maxWait));
     }

     function timerExpired() {
       var time = now();
       if (shouldInvoke(time)) {
         return trailingEdge(time);
       }
       // Restart the timer.
       timerId = setTimeout(timerExpired, remainingWait(time));
     }

     function trailingEdge(time) {
       timerId = undefined;

       // Only invoke if we have `lastArgs` which means `func` has been
       // debounced at least once.
       if (trailing && lastArgs) {
         return invokeFunc(time);
       }
       lastArgs = lastThis = undefined;
       return result;
     }

     function cancel() {
       if (timerId !== undefined) {
         clearTimeout(timerId);
       }
       lastInvokeTime = 0;
       lastArgs = lastCallTime = lastThis = timerId = undefined;
     }

     function flush() {
       return timerId === undefined ? result : trailingEdge(now());
     }

     function debounced() {
       var time = now(),
           isInvoking = shouldInvoke(time);

       lastArgs = arguments;
       lastThis = this;
       lastCallTime = time;

       if (isInvoking) {
         if (timerId === undefined) {
           return leadingEdge(lastCallTime);
         }
         if (maxing) {
           // Handle invocations in a tight loop.
           clearTimeout(timerId);
           timerId = setTimeout(timerExpired, wait);
           return invokeFunc(lastCallTime);
         }
       }
       if (timerId === undefined) {
         timerId = setTimeout(timerExpired, wait);
       }
       return result;
     }
     debounced.cancel = cancel;
     debounced.flush = flush;
     return debounced;
   }

   /** Error message constants. */
   var FUNC_ERROR_TEXT = 'Expected a function';

   /**
    * Creates a throttled function that only invokes `func` at most once per
    * every `wait` milliseconds. The throttled function comes with a `cancel`
    * method to cancel delayed `func` invocations and a `flush` method to
    * immediately invoke them. Provide `options` to indicate whether `func`
    * should be invoked on the leading and/or trailing edge of the `wait`
    * timeout. The `func` is invoked with the last arguments provided to the
    * throttled function. Subsequent calls to the throttled function return the
    * result of the last `func` invocation.
    *
    * **Note:** If `leading` and `trailing` options are `true`, `func` is
    * invoked on the trailing edge of the timeout only if the throttled function
    * is invoked more than once during the `wait` timeout.
    *
    * If `wait` is `0` and `leading` is `false`, `func` invocation is deferred
    * until to the next tick, similar to `setTimeout` with a timeout of `0`.
    *
    * See [David Corbacho's article](https://css-tricks.com/debouncing-throttling-explained-examples/)
    * for details over the differences between `_.throttle` and `_.debounce`.
    *
    * @static
    * @memberOf _
    * @since 0.1.0
    * @category Function
    * @param {Function} func The function to throttle.
    * @param {number} [wait=0] The number of milliseconds to throttle invocations to.
    * @param {Object} [options={}] The options object.
    * @param {boolean} [options.leading=true]
    *  Specify invoking on the leading edge of the timeout.
    * @param {boolean} [options.trailing=true]
    *  Specify invoking on the trailing edge of the timeout.
    * @returns {Function} Returns the new throttled function.
    * @example
    *
    * // Avoid excessively updating the position while scrolling.
    * jQuery(window).on('scroll', _.throttle(updatePosition, 100));
    *
    * // Invoke `renewToken` when the click event is fired, but not more than once every 5 minutes.
    * var throttled = _.throttle(renewToken, 300000, { 'trailing': false });
    * jQuery(element).on('click', throttled);
    *
    * // Cancel the trailing throttled invocation.
    * jQuery(window).on('popstate', throttled.cancel);
    */
   function throttle(func, wait, options) {
     var leading = true,
         trailing = true;

     if (typeof func != 'function') {
       throw new TypeError(FUNC_ERROR_TEXT);
     }
     if (isObject(options)) {
       leading = 'leading' in options ? !!options.leading : leading;
       trailing = 'trailing' in options ? !!options.trailing : trailing;
     }
     return debounce(func, wait, {
       'leading': leading,
       'maxWait': wait,
       'trailing': trailing
     });
   }

   const options = {
     modules: {
       toolbar: false,
     },
     placeholder: "备注",
     theme: "snow",
   };
   const quill = new Quill("#editor", options);

   function getSelectionFormats() {
     const range = quill.getSelection();
     return range == null ? {} : quill.getFormat(range);
   }

   function isFormatActive(type) {
     const formats = getSelectionFormats();
     return formats[type] != null;
   }

   // 加粗操作
   addEventListener("toolbar.boldButtonTapped", () => {
     const isActive = isFormatActive("bold");

     quill.format("bold", !isActive);
   });

   // 有序列表操作
   addEventListener("toolbar.numberListButtonTapped", () => {
     const formats = getSelectionFormats();

     quill.format("list", formats.list === "ordered" ? false : "ordered");
   });

   // 无序列表操作
   addEventListener("toolbar.dashListButtonTapped", () => {
     const formats = getSelectionFormats();

     quill.format("list", formats.list === "bullet" ? false : "bullet");
   });

   // 勾选列表操作
   addEventListener("toolbar.checkBoxListButtonTapped", () => {
     const formats = getSelectionFormats();

     if (formats.list === "checked" || formats.list === "unchecked") {
       quill.format("list", false);
     } else {
       quill.format("list", "unchecked");
     }
   });

   function handleIndentChange(modifier) {
     const formats = getSelectionFormats();
     const indent = parseInt(formats.indent || 0, 10);
     modifier *= formats.direction === "rtl" ? -1 : 1;

     quill.format("indent", indent + modifier);
   }

   // 增加缩进操作
   addEventListener("toolbar.increaseIndentButtonTapped", () => {
     handleIndentChange(1);
   });

   // 减少缩进操作
   addEventListener("toolbar.decreaseIndentButtonTapped", () => {
     handleIndentChange(-1);
   });

   // 清除聚焦状态
   addEventListener("toolbar.blurButtonTapped", () => {
     quill.blur();
   });

   // 获取编辑器内容
   addEventHandler("editor.fetchContent", () => {
     return quill.getContents();
   });

   // 设置编辑器内容
   addEventListener("editor.setContent", (newContent) => {
     quill.setContents(JSON.parse(newContent), "api");
   });

   function noticeNativeTextChange(delta) {
     callNative("editor.contentChange", delta);
   }

   // 5s 内没有改动，再进行同步
   const throttledNotice = throttle(noticeNativeTextChange, 5000, {
     leading: false,
   });

   quill.on("text-change", (delta, oldDelta, source) => {
     if (source == "user") {
       throttledNotice(quill.getContents());
     }
   });

 })();
