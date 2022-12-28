// https://peggyjs.org/documentation.html

// peggy arithmetics.pegjs
// peggy -o arithmetics-parser.js arithmetics.pegjs

{{
  // globaly available functions
  const EXPRESSION = 'Expressoin';
  const TERM = 'Term';
  const PLUS = 'Plus';
  const MINUS = 'Minus';
  const FACTOR = 'Factor';
  const MULTI = 'Multi';
  const DIV = 'Div';
  const NUMBER = 'Number';

  function getOperatorType(item){
    switch (item) {
      case '+': return PLUS;
      case '-': return MINUS;
      case '/': return DIV;
      case '*': return MULTI;
      default:
        throw new Error(`${item} is not a number, no type matched`);
    }
  }

  function getOperaotr(item) {
    return {
      type: getOperatorType(item),
      // toParse: item,
      value: [item],
    }
  }

  function toObject({ type, value }) {
    return {
      type, value,
    }
  }

}};

// {
//   if(true) {};
// }

Expression
  = head:Term tail:(_ ("+" / "-") _ Term)* {
    if (tail.length === 0) return {
      type: EXPRESSION,
      value: [head]
    }
    const reduced = tail.reduce(function(acc, element) {
      const next = {
        type: EXPRESSION,
        value: [
          acc,
          getOperaotr(element[1]),
          element[3]
        ]
      }
      acc = next;
      return acc;
    }, head)
    return reduced;
  }
  // head:Term tail:(_ ("+" / "-") _ Term)* {
  //     return tail.reduce(function(result, element) {
  //       if (element[1] === "+") { return result + element[3]; }
  //       if (element[1] === "-") { return result - element[3]; }
  //     }, head);
  //   }



Term
  = head:Factor tail:(_ ("*" / "/") _ Factor)* {
    if (tail.length === 0) return {
      type: TERM,
      value: [head]
    }
    const reduced = tail.reduce(function(acc, element) {
      const next = {
        type: TERM,
        value: [
          acc,
          getOperaotr(element[1]),
          element[3]
        ]
      }
      acc = next;
      return acc;
    }, head)
    return reduced
  }
  // {
  //     return tail.reduce(function(result, element) {
  //       if (element[1] === "*") { return result * element[3]; }
  //       if (element[1] === "/") { return result / element[3]; }
  //     }, head);
  //   }

Factor
  = "(" _ expr:Expression _ ")"
  {
    return {
      value: [expr],
      type: FACTOR,
    };
  }
  // / Integer
  / int:Integer {
    return {
      type: FACTOR,
      value: [int],
    }
  }


Integer "integer"
    = _ [0-9]+ { 
        const val = parseInt(text(), 10);
        return toObject({
          type: NUMBER, 
          // toParse: `${val}`, 
          value: [val]
        }) 
      }
  // = _ [0-9]+ { return parseInt(text(), 10); }

_ "whitespace"
  = [ \t\n\r]*
  