{{
    import { 
        TAG, PARAM, QUOTED, COMMENT, BRACKET, NEW_LINE, CONTENT, ASSIGN, SPACE, VAL,
        R, TAB,
    } from "../constants/htmlColors.js";

    const singleTagsList = ['br', 'hr', 'img', 'input', 'keygen', 'link', 'meta', 'param', 'source', 'track', 'wbr']

    function getTagContent(parsedResult){
        const result = parsedResult.find((item) => item.type === TAG)
        return result?.content;
    }

    function procesTag({
        beforeBracketSpace,
        beforeNameSpace, 
        afterBracketSpace,
        close,
        name,
    }) {
        let output = [];
        if (beforeBracketSpace) output = [...output, ...beforeBracketSpace]
        output.push({type: BRACKET, content: '<'})
        if (beforeNameSpace) output = [...output, ...beforeNameSpace]
        if (close !== null) output.push({type: BRACKET, content: '/'})
        if (name) output.push({type: TAG, content: name})
        output.push({type: BRACKET, content: '>'})
        if (afterBracketSpace) output = [...output, ...afterBracketSpace]
        return output;
    }

}};

// Expression 
//     = 
//     // tags:Tag* 
//     // {
//     //     const result = tags.flat();
//     //     return result;

//     // }
//      expressions:TagExpression* 
//     {
//         // Expression = expressions:TagExpression {
//         const result = expressions.flat();
//         return result;
//     }

TagExpression = 
n1:N "<" n2:N openTagName:Name? ">" n3:N
    enclosedString:ContentString
n4:N "<" n5:N close:"/"? closeTagName:Name? ">" n6:N
{
    if (openTagName !== closeTagName) {
        return null;
        throw new Error(`Open tag ${openTagName} and close tag ${closeTagName} are different`)
    }
    const openTag = procesTag({
        beforeBracketSpace: n1,
        beforeNameSpace: n2,
        afterBracketSpace: n3,
        close: null,
        name: openTagName,
    });
    const content = {
        type: CONTENT, content: enclosedString.join('')
    };
    const closeTag = procesTag({
        beforeBracketSpace: n4,
        beforeNameSpace: n5,
        afterBracketSpace: n6,
        close,
        name: closeTagName,
    })
    if (enclosedString.join('') === "") return [...openTag, ...closeTag].flat();
    return [...openTag, content, ...closeTag].flat();
} / tag:Tag {
    const tagName = getTagContent(tag);
    if (singleTagsList.includes(tagName)) {
        return tag
    }
    return null;
}

Tag = n1:N "<" n2:N close:"/"? tagName:Name? ">" n3:N
      {
        let output = [];
        if (n1) output = [...output, ...n1]
        output.push({type: BRACKET, content: '<'})
        if (n2) output = [...output, ...n2]
        if (close) output.push({type: BRACKET, content: '/'})
        if (tagName) output.push({type: TAG, content: tagName})
        output.push({type: BRACKET, content: '>'})
        if (n3) output = [...output, ...n3]
        return output.flat();
      }





// Tag = TagBracket TagBracket / 
//       TagBracket name:Name _ attr:Attribute* TagBracket {
//         console.log('Tag', name, attr)
//         const output = [];
//         if (name) output.push({
//             type: TAG,
//             content: name,
//         })
//         if (attr) output.push({
//             type: PARAM,
//             content: attr,
//         })
//         return output;
//       }

// Attribute = attName:Name { return text() }
// // Attribute = attName:Name _ val:( _ Assign _ Value?) {

// // }

// TagBracket = ob:'<' / cb:'>' / cl: '<' _ '/' {
//     console.log('TagBracket', ob, cb, cl)
//     if (cl) {
//         return [
//            { type: BRACKET, content: '<' },
//            { type: BRACKET, content: '/' }
//         ]
//     }
//     return [{
//         type: BRACKET,
//         content: ob | cb
//     }]
// }

// // Value = String / Boolean { return text() }

// // String = "\""str:StrText"\"" / "\'"str1:StrText"\'" / "\`"str2:StrText"\"" {
// //     console.log('String', str, str1, str2)
// //     return text();    
// // }

// // StrText = [.]* { 
// //     console.log('String', text())
// //     return text() 
// // }

// // Boolean = "true" / "false" {  
// //     console.log('boolean', text())
// //     return text() 
// // }

// Assign = '=' { return text() }

ContentString = [^<>]* / "" { return text() };

Name = [a-zA-Z]+ { return text() };

_ "whitespace"
  = [ \t\n\r]*

// S = t:[\t] / n:[\n] / r:[\r] / s:[" "] {
//     if(n) return {
//         type: NEW_LINE,
//         content:'',
//     }
// }

S = space:[ \t\n\r] {
    if(space.match(/\n/)) return {
        type: NEW_LINE,
        content:'',
    }
    if(space === " ") return {
        type: SPACE,
        content: ' ',
    }
    if(space.match(/\t/)) return {
        type: TAB,
        content: "/t"
    }
    if(space.match(/\r/)) return {
        type: TAB,
        content: "/r"
    }

}

N = newLines:S* {
    return newLines.reduce((acc, symb) => {
        if (symb) console.log('NEW LINE EXISTS')
        if (symb) acc.push(symb)

        return acc;
    }, []);
}
