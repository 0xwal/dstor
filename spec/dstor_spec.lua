---
--- Created By 0xWaleed <https://github.com/0xWaleed>
--- DateTime: 05/03/2022 6:47 AM
---

require('dstor')

describe('data storage', function()
    local dstor
    before_each(function()
        dstor = Dstor.new()
    end)

    it('has :set', function()
        assert.is_function(dstor.set)
    end)

    it('able to set a value', function()
        dstor:set('name', 'Waleed')
        assert.is_equal('Waleed', dstor:get('name'))
    end)

    it('able to set existent value', function()
        dstor:set('name', 'Waleed')
        dstor:set('name', 'BISOON')
        assert.is_equal('BISOON', dstor:get('name'))
    end)

    describe('get', function()
        it('exist', function()
            assert.is_function(dstor.get)
        end)

        it('returns nil for non existent value', function()
            assert.is_nil(dstor:get('name'))
        end)

        it('should return all store when we call get with * as key', function()
            dstor:set('cpu', 'arm')
            dstor:set('ram', 'ddr4')
            assert.are_same({
                cpu = 'arm',
                ram = 'ddr4'
            }, dstor:get('*'))
        end)

        it('returns only the specified key for when calling get with *.`key name`', function()
            dstor:set('cpu', {
                extra = 1,
                type  = 'arm'
            })
            dstor:set('ram', {
                extra = 'extra',
                type  = 'ddr4'
            })
            assert.are_same({
                cpu = {
                    type = 'arm'
                },
                ram = {
                    type = 'ddr4'
                }
            }, dstor:get('*.type'))
        end)

        it('skips the non table value in store when calling get with *.`key name`', function()
            dstor:set('cpu', 3)
            dstor:set('ram', {
                extra = 'extra',
                type  = 'ddr4'
            })
            assert.are_same({
                ram = {
                    type = 'ddr4'
                }
            }, dstor:get('*.type'))
        end)

        it('should able to get all key sub elements', function()
            dstor:set('player.1', 11)
            dstor:set('player.2', 22)
            dstor:set('players.2', 22) -- should not show

            assert.are_same({
                ['1'] = 11,
                ['2'] = 22,
            }, dstor:get('player.*'))
        end)

        it('should able to get all sub elements in nested table', function()
            dstor:set('players.1.games.1', 11)
            dstor:set('players.1.games.2', 33)
            dstor:set('players.2.games.2', 22)

            assert.are_same({
                ['1'] = 11,
                ['2'] = 33,
            }, dstor:get('players.1.games.*'))
        end)

        it('should be able to get sub elements for specific column', function()
            dstor:set('players.1.games.1', { name = 'gta5', extra = '111' })
            dstor:set('players.1.games.2', { name = 'rdr4', extra = 4444 })
            dstor:set('players.2.games.2', 22)

            assert.are_same({
                ['1'] = { name = 'gta5' },
                ['2'] = { name = 'rdr4' },
            }, dstor:get('players.1.games.*.name'))
        end)
    end)
end)
