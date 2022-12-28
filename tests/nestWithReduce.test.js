const nest = (arr) => {
    const result = arr.reduce((acc, item) => {
        const next = {
            value: item,
            next: acc,
        };
        acc = next;
        return acc;
    }, null)
    return result;
}

describe('Nesting with reduce', () => {
    it('Should return a nested object', () => {
        const input = [1,2,3,4,5]
        const expected = {
            value:5,
            next:{
                value: 4,
                next: {
                    value: 3,
                    next: {
                        value: 2,
                        next: {
                            value: 1,
                            next: null,
                        }
                    }
                }
            }
        };
        const result = nest(input);
        expect(result).toEqual(expected);
    })
});