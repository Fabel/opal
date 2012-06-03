module JSON
  def self.parse(source)
    %x{
      var json = json_parse(source);
      return to_opal(json);
    }
  end

  %x{
    var json_parse;
    var cx = /[\\u0000\\u00ad\\u0600-\\u0604\\u070f\\u17b4\\u17b5\\u200c-\\u200f\\u2028-\\u202f\\u2060-\\u206f\\ufeff\\ufff0-\\uffff]/g;

    if (typeof JSON !== 'undefined') {
      json_parse = JSON.parse;
    }
    else {
      json_parse = function(text) {
        console.log("using opal's JSON.parse");

        text = String(text);
        cx.lastIndex = 0;

        if (cx.test(text)) {
          text = text.replace(cx, function(a) {
            return '\\\\u' + ('0000' + a.charCodeAt(0).toString(16)).slice(-4);
          });
        }

        if (/^[\\],:{}\\s]*$/
                    .test(text.replace(/\\\\(?:["\\\\\\/bfnrt]|u[0-9a-fA-F]{4})/g, '@')
                        .replace(/"[^"\\\\\\n\\r]*"|true|false|null|-?\\d+(?:\\.\\d*)?(?:[eE][+\\-]?\\d+)?/g, ']')
                        .replace(/(?:^|:|,)(?:\\s*\\[)+/g, ''))) {

                return eval('(' + text + ')');
        }

        throw new SyntaxError('JSON.parse');
      };
    }


    function to_opal(value) {
      switch (typeof value) {
        case 'string':
          return value;

        case 'number':
          return value;

        case 'boolean':
          return !!value;

        case 'null':
          return null;

        case 'object':
          if (!value) return null;

          if (Object.prototype.toString.apply(value) === '[object Array]') {
            var arr = [];

            for (var i = 0, ii = value.length; i < ii; i++) {
              arr.push(to_opal(value[i]));
            }

            return arr;
          }
          else {
            var hash = #{ {} }, v, map = hash.map;

            for (var k in value) {
              if (Object.hasOwnProperty.call(value, k)) {
                v = to_opal(value[k]);
                map[k] = [k, v];
              }
            }
          }

          return hash;
      }
    };
  }
end