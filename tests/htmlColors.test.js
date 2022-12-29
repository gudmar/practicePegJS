// const peggy = {
//     SyntaxError: peg$SyntaxError,
//     parse: peg$parse
//   }
  
//   export { peggy };

import { peggy } from "../parsers/htmlColors.js";
import { 
    TAG, PARAM, QUOTED, COMMENT, BRACKET, NEW_LINE, CONTENT, ASSIGN, SPACE, VAL,
    R, TAB,
} from "../constants/htmlColors.js";

describe('Testing htmlColors', () => {
    it('Should process empty tag brackets', () => {
        const input = '<></>';
        const expected = [
            { content: '<', type: BRACKET },
            { content: '>', type: BRACKET },

            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: '>', type: BRACKET }
        ]
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    })

    it('Should return null for just an opening tag', () => {
        const input = '<div>';
        const result = peggy.parse(input);
        expect(result).toBeNull();
    })

    it('Should process a single tag if it is a special tag', () => {
        const input = '<br>'
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'br', type: TAG },
            { content: '>', type: BRACKET },
        ]
        const result = peggy.parse(input);
        expect(result).toEqual(expected);         
    });

    it('Should process a single closing tag if it is a special tag', () => {
        const input = '</img>'
        const expected = [
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'img', type: TAG },
            { content: '>', type: BRACKET },
        ]
        const result = peggy.parse(input);
        expect(result).toEqual(expected);         
    });

    it('Should process open and close tag <a></a>', () => {
        const input = '<a></a>';
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '>', type: BRACKET },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '>', type: BRACKET },
        ]
        const result = peggy.parse(input);
        expect(result).toEqual(expected);  
    })

    it('Should process open and close tag with a space separating them <a>  </a>', () => {
        const input = '<a>  </a>';
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '>', type: BRACKET },
            { content: ' ', type: SPACE },
            { content: ' ', type: SPACE },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '>', type: BRACKET },
        ]
        const result = peggy.parse(input);
        expect(result).toEqual(expected);  
    })    

    it('Should break line if there is a line separator <a></a>', () => {
        const input = `<a>
</a>`
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '>', type: BRACKET },
            { content: '', type: NEW_LINE },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '>', type: BRACKET },
        ]
        const result = peggy.parse(input);
        expect(result).toEqual(expected);  
    })
    it('Should process a few new line, space symbols', () => {
        const input = `<a>

  </a>`
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '>', type: BRACKET },
            { content: '', type: NEW_LINE },
            { content: '', type: NEW_LINE },
            { content: ' ', type: SPACE },
            { content: ' ', type: SPACE },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '>', type: BRACKET },
        ]
        const result = peggy.parse(input);
        expect(result).toEqual(expected);  
    })

    it('Should put content between a tag correctly', () => {
        const input = '<i>my content</i>'
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'i', type: TAG },
            { content: '>', type: BRACKET },
            { content: 'my content', type: CONTENT },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'i', type: TAG },
            { content: '>', type: BRACKET },
        ]
        const result = peggy.parse(input);
        expect(result).toEqual(expected);  
    })

    it('Should return null in case open tag is different than closing tag', () => {
        const input = '<i>my content</b>'
        const result = peggy.parse(input);
        expect(result).toBeNull();
    })

    it('Should put attribute color correctly', () => {
        const input = '<b disabled>my content</b>'
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'b', type: TAG },
            { content: '', type: SPACE },
            { content: 'disabled', type: PARAM },
            { content: '>', type: BRACKET },
            { content: 'my content', type: CONTENT },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'b', type: TAG },
            { content: '>', type: BRACKET },
        ]
    })

    it('Should put attribute with its value color correctly', () => {
        const input = '<b disabled = true>my content</b>'
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'b', type: TAG },
            { content: '', type: SPACE },
            { content: 'disabled', type: PARAM },
            { content: '', type: SPACE },
            { content: '=', type: ASSIGN },
            { content: '', type: SPACE },
            { content: 'true', type: VAL },
            { content: '>', type: BRACKET },
            { content: 'my content', type: CONTENT },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'b', type: TAG },
            { content: '>', type: BRACKET },
        ]
    })

    it('Should process a value with quotation mark in it', () => {
        const input = '<button disabled = true width="14px" data-attr = "custom param">my content</button>'
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'button', type: TAG },
            { content: '', type: SPACE },
            { content: 'disabled', type: PARAM },
            { content: '', type: SPACE },
            { content: '=', type: ASSIGN },
            { content: '', type: SPACE },
            { content: 'true', type: VAL },
            { content: 'data-attr', type: PARAM },
            { content: '', type: SPACE },
            { content: '=', type: ASSIGN },
            { content: '', type: SPACE },
            { content: '"custom param"', type: VAL },
            { content: '>', type: BRACKET },
            { content: 'my content', type: CONTENT },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'button', type: TAG },
            { content: '>', type: BRACKET },
        ]
    })

    it('Should proces param with nested quotation correctly', () => {
        const input = '<div data-attr = \'this is some "quoted" value\'>'
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'div', type: TAG },
            { content: '', type: SPACE },
            { content: 'data-attr', type: PARAM },
            { content: '', type: SPACE },
            { content: '=', type: ASSIGN },
            { content: '', type: SPACE },
            { content: 'this is some "quoted" value', type: VAL },
        ]
    })

    it('Should proces comments correctly', () => {
        const input = '<!--This is a comment-->'
        const expected = [
            { content: '<!--This is a comment-->', type: COMMENT },
        ]
    })

    it('Should process multiline comments corectly', () => {
        const input = `<!--This is a multiline
                            comment-->`
        const expected = [
            { content: '<!--This is a multiline', type: COMMENT },
            { content: '', type: NEW_LINE },
            { content: 'comment-->', type: COMMENT },
        ]
    })

    it('Should process a longer fragment correcty', () => {
        const input = `
        <div style="color: red" class="some-class">
        <span>Title</span> <!-- comment -->
        <a 
            data-custom = "My custom data content 
            more lines"
        >
            Some multiline
            text
        </a>
        `
        const expected = [
            { content: '<', type: BRACKET },
            { content: 'div', type: TAG },
            { content: '', type: SPACE },
            { content: 'style', type: PARAM },
            { content: '=', type: ASSIGN },
            { content: '', type: SPACE },
            { content: '"color: red"', type: VAL},
            { content: '', type: SPACE },
            { content: 'class', type: PARAM },
            { content: '=', type: ASSIGN },
            { content: 'some-class', type: VAL},
            { content: '>', type: BRACKET },
            { content: '', type: NEW_LINE },

            { content: '<', type: BRACKET },
            { content: 'span', type: TAG },
            { content: '>', type: BRACKET },
            { content: 'Title', type: CONTENT },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'span', type: TAG },
            { content: '>', type: BRACKET },
            { content: '', type: SPACE },
            { content: '<!-- comment -->', type: COMMENT },
            { content: '', type: NEW_LINE },

            { content: '<', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '', type: NEW_LINE },
            { content: 'data-custom', type: PARAM },
            { content: '', type: SPACE },
            { content: '=', type: ASSIGN },
            { content: '', type: SPACE },
            { content: 'My custom data content ', type: CONTENT },
            { content: '', type: NEW_LINE },
            { content: 'more lines', type: CONTENT },
            { content: '', type: NEW_LINE },
            { content: '>', type: BRACKET },
            { content: '', type: NEW_LINE },
            { content: 'Some multiline', type: CONTENT },
            { content: '', type: NEW_LINE },
            { content: 'text', type: CONTENT },
            { content: '', type: NEW_LINE },
            { content: '<', type: BRACKET },
            { content: '/', type: BRACKET },
            { content: 'a', type: TAG },
            { content: '>', type: BRACKET },

        ]
    })
});
