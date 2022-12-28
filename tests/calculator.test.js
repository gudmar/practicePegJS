// const peggy = {
//     SyntaxError: peg$SyntaxError,
//     parse: peg$parse
//   }
  
//   export { peggy };

import { peggy } from "../parsers/calculator.js";
import { Helper } from "../functions/calculatorHelper.js"

describe('Testing calculator', () => {
    const H = Helper;
    const h = new Helper({ getTokenType: H.getTokenType })

    it('Should process 1', () => {
        const input = '1';
        const expected = h.nest({
                types: [H.EXPRESSION],
                valueArray: [
                            h.nest({
                                types: [H.TERM, H.FACTOR, H.NUMBER],
                                valueArray: [1]
                            })
                        ]
            }) 
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });

    it('Should parse a sum 1 + 2', () => {
        const input = `1 + 2`;
        const expected = h.nest({
                types: [H.EXPRESSION],
                valueArray: [
                            h.nest({
                                types: [H.TERM, H.FACTOR, H.NUMBER],
                                valueArray: [1]    
                            }),
                            h.getToken('+'),
                            h.nest({
                                types: [H.TERM, H.FACTOR, H.NUMBER],
                                valueArray: [2]
                                    }),
                        ]
            }) 
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });

    it('Should parse a sum 1 * 2', () => {
        const input = `1 * 2`;
        const expected = h.nest({
                types: [H.EXPRESSION, H.TERM],
                valueArray: [
                            h.nest({
                                types: [H.FACTOR, H.NUMBER],
                                valueArray: [1]    
                            }),
                            h.getToken('*'),
                            h.nest({
                                types: [H.FACTOR, H.NUMBER],
                                valueArray: [2]
                                    }),
                        ]
            }) 
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });

    it('Should parse a sum of products correctly: 1 * 2 + 3 * 4', () => {
        const input = '1 * 2 + 3 * 4';
        const expected = h.nest({
                types: [H.EXPRESSION],
                valueArray: [
                            h.nest({
                                types: [H.TERM],
                                valueArray: [
                                    h.nest({
                                        types: [H.FACTOR, H.NUMBER],
                                        valueArray: [1]    
                                    }),
                                    h.getToken('*'),
                                    h.nest({
                                        types: [H.FACTOR, H.NUMBER],
                                        valueArray: [2]
                                            }),
                                ]    
                            }),
                            h.getToken('+'),
                            h.nest({
                                types: [H.TERM],
                                valueArray: [
                                    h.nest({
                                        types: [H.FACTOR, H.NUMBER],
                                        valueArray: [3]    
                                    }),
                                    h.getToken('*'),
                                    h.nest({
                                        types: [H.FACTOR, H.NUMBER],
                                        valueArray: [4]
                                            }),
                                ]    
                            }),
                        ]
            }) 
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });

    it('Should parse 1 + 2 + 3 correctly', () => {
        const input = '1 + 2 + 3';
        const expected = h.nest({
                types: [H.EXPRESSION],
                valueArray: [
                    h.nest({
                        types: [H.EXPRESSION],
                        valueArray: [
                                    h.nest({
                                        types: [H.TERM, H.FACTOR, H.NUMBER],
                                        valueArray: [1]    
                                    }),
                                    h.getToken('+'),
                                    h.nest({
                                        types: [H.TERM, H.FACTOR, H.NUMBER],
                                        valueArray: [2]
                                            }),
                                ]
                    }),
                    h.getToken('+'),
                    h.nest({
                        types: [H.TERM, H.FACTOR, H.NUMBER],
                        valueArray: [3]
                    }),
                ]
            })
            const result = peggy.parse(input);
            expect(result).toEqual(expected);
    })

    it('Should parse 1 * 2 + 3 * 4 correctly', () => {
        const input = '1 * 2 + 3 * 4';
        const expected = h.nest({
                types: [H.EXPRESSION],
                valueArray: [
                            h.nest({
                                types: [H.TERM],
                                valueArray: [
                                    h.nest({
                                        types: [H.FACTOR, H.NUMBER],
                                        valueArray: [1]    
                                    }),
                                    h.getToken('*'),
                                    h.nest({
                                        types: [H.FACTOR, H.NUMBER],
                                        valueArray: [2]
                                            }),
                                ]    
                            }),
                            h.getToken('+'),
                            h.nest({
                                types: [H.TERM],
                                valueArray: [
                                    h.nest({
                                        types: [H.FACTOR, H.NUMBER],
                                        valueArray: [3]    
                                    }),
                                    h.getToken('*'),
                                    h.nest({
                                        types: [H.FACTOR, H.NUMBER],
                                        valueArray: [4]
                                            }),
                                ]    
                            }),
                        ]
            }) 
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });

    it('Should parse 1 + 2 * 3 + 4 correctly', () => {
        const input = '1 + 2 * 3 + 4';

        const expected = h.nest({
            types: [H.EXPRESSION],
            valueArray: [
                h.nest({
                    types: [H.EXPRESSION],
                    valueArray: [
                        h.nest({
                            types: [H.TERM, H.FACTOR, H.NUMBER],
                            valueArray: [1]
                        }),
                        h.getToken('+'),
                        h.nest({
                            types: [H.TERM],
                            valueArray: [
                                h.nest({
                                    types: [ H.FACTOR, H.NUMBER ],
                                    valueArray: [2]
                                }),
                                h.getToken('*'),
                                h.nest({
                                    types: [ H.FACTOR, H.NUMBER ],
                                    valueArray: [3]
                                }),
                            ]
                        }),
                    ],
                }),
                h.getToken('+'),
                h.nest({
                    types: [H.TERM, H.FACTOR, H.NUMBER],
                    valueArray: [4]
                }),
            ]
        })
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });

    it('Should parse (1) correctly', () => {
        const input = '(1)';
        const expected = h.nest({
            types: [H.EXPRESSION, H.TERM, H.FACTOR],
            valueArray: [
                        h.nest({
                            types: [H.EXPRESSION, H.TERM, H.FACTOR, H.NUMBER],
                            valueArray: [1]
                        })
                    ]
        }) 
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });
    it('Should parse (1 + 2) correctly', () => {
        const input = '(1 + 2)';
        const expected = h.nest({
            types: [H.EXPRESSION, H.TERM, H.FACTOR],
            valueArray: [
                        h.nest({
                            types: [H.EXPRESSION],
                            valueArray: [
                                        h.nest({
                                            types: [H.TERM, H.FACTOR, H.NUMBER],
                                            valueArray: [1]    
                                        }),
                                        h.getToken('+'),
                                        h.nest({
                                            types: [H.TERM, H.FACTOR, H.NUMBER],
                                            valueArray: [2]
                                                }),
                                    ]
                        })
                    ]
        }) 
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });
    it('Should parse 1 + (2 + 3) correctly', () => {
        const input = '1 + ( 2 + 3 )';
        const expected = h.nest({
            types: [H.EXPRESSION],
            valueArray: [
                            h.nest({
                                types: [H.TERM, H.FACTOR, H.NUMBER],
                                valueArray: [1]    
                            }),
                            h.getToken('+'),
                            h.nest({
                                types: [H.TERM, H.FACTOR, H.EXPRESSION],
                                valueArray: [
                                    h.nest({
                                        types: [H.TERM, H.FACTOR, H.NUMBER],
                                        valueArray: [2]    
                                    }),
                                    h.getToken('+'),
                                    h.nest({
                                        types: [H.TERM, H.FACTOR, H.NUMBER],
                                        valueArray: [3]
                                            }),
                                ]
                                    }),
                    ]
        }) 
        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });
    it('Should parse 1 * (2 + 3) * 4 correctly', () => {
        const input = '1 * ( 2 + 3 ) * 4';
        const expected = h.nest({
            types: [H.EXPRESSION, H.TERM],
            valueArray: [
                h.nest({
                    types: [H.TERM],
                    valueArray: [
                                    h.nest({
                                        types: [H.FACTOR, H.NUMBER],
                                        valueArray: [1]    
                                    }),
                                    h.getToken('*'),
                                    h.nest({
                                        types: [H.FACTOR, H.EXPRESSION],
                                        valueArray: [
                                            h.nest({
                                                types: [H.TERM, H.FACTOR, H.NUMBER],
                                                valueArray: [2]    
                                            }),
                                            h.getToken('+'),
                                            h.nest({
                                                types: [H.TERM, H.FACTOR, H.NUMBER],
                                                valueArray: [3]
                                                    }),
                                        ]
                                            }),
                            ]
                }),
                h.getToken('*'),
                h.nest({
                    types: [H.FACTOR, H.NUMBER],
                    valueArray: [4]
                })
            ]
        })

        const result = peggy.parse(input);
        expect(result).toEqual(expected);
    });
    it('Should parse (1 + 2) * (3 + 4) correctly', () => {
        const input = '(1 + 2) * (3 + 4)'
        const sum = ({types = [ H.TERM, H.FACTOR, H.NUMBER ], val1, val2}) =>
                [
                    h.nest({
                        types: [...types],
                        valueArray: [val1]
                    }),
                    h.getToken('+'), 
                    h.nest({
                        types: [...types],
                        valueArray: [val2]
                    })
                ]
        const sumInBracket = ({types = [ H.TERM, H.FACTOR, H.NUMBER ], val1, val2}) => {
            const result = h.nest({
                types: [H.EXPRESSION],
                valueArray: sum({types, val1, val2})
            })
            return result;
        }
        const expected = h.nest({
            types: [H.EXPRESSION, H.TERM],
            valueArray: [
                h.nest({
                    types: [H.FACTOR],
                    valueArray: [sumInBracket({val1: 1, val2: 2})]
                }),
                h.getToken('*'),
                h.nest({
                    types: [H.FACTOR],
                    valueArray: [sumInBracket({val1: 3, val2: 4})]
                }),
            ]
        })
        const result = peggy.parse(input);
        expect(result).toEqual(expected)
    });

    it('Should parse (1 + 2) * (3 + 4) * (5 + 6) correctly', () => {
        const input = '(1 + 2) * (3 + 4) * (5 + 6)'
        const sum = ({types = [ H.TERM, H.FACTOR, H.NUMBER ], val1, val2}) =>
                [
                    h.nest({
                        types: [...types],
                        valueArray: [val1]
                    }),
                    h.getToken('+'), 
                    h.nest({
                        types: [...types],
                        valueArray: [val2]
                    })
                ]
        const sumInBracket = ({types = [ H.TERM, H.FACTOR, H.NUMBER ], val1, val2}) => {
            const result = h.nest({
                types: [H.EXPRESSION],
                valueArray: sum({types, val1, val2})
            })
            return result;
        }
        const from1To4 = h.nest({
            types: [H.TERM],
            valueArray: [
                h.nest({
                    types: [H.FACTOR],
                    valueArray: [sumInBracket({val1: 1, val2: 2})]
                }),
                h.getToken('*'),
                h.nest({
                    types: [H.FACTOR],
                    valueArray: [sumInBracket({val1: 3, val2: 4})]
                }),
            ]
        })

        const expected = h.nest({
            types: [H.EXPRESSION, H.TERM],
            valueArray: [
                from1To4,
                h.getToken('*'),
                h.nest({
                    types: [H.FACTOR],
                    valueArray: [sumInBracket({val1: 5, val2: 6})]
                }),
            ]
        })
        const result = peggy.parse(input);
        expect(result).toEqual(expected)
    });

})
