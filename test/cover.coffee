#  Copyright (C) 2014 Yusuke Suzuki <utatane.tea@gmail.com>
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#
#    * Redistributions of source code must retain the above copyright
#      notice, this list of conditions and the following disclaimer.
#    * Redistributions in binary form must reproduce the above copyright
#      notice, this list of conditions and the following disclaimer in the
#      documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
#  DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
#  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
#  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#  THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

'use strict'

fs = require 'fs'
expect = require('chai').expect
Promise = require('bluebird')
PromisedFS = require('promised-io/fs')
child_process = require 'child_process'

describe 'coverage', ->
    it 'simple', (done) ->
        proc = child_process.spawn 'node', [
            'bin/ibrik'
            'cover'
            'test/fixture/test001.coffee'
            '--dir'
            'tmp/test/test001.coffee'
            '--no-default-excludes'
            '--self-test'
        ]
        proc.stdout.on 'data', (data) -> process.stdout.write(data)
        proc.stderr.on 'data', (data) -> process.stdout.write(data)
        proc.on 'exit', (code) ->
            if code
                done code
                return

            Promise.all([
                PromisedFS.readFile('tmp/test/test001.coffee/coverage.json', 'utf-8')
                PromisedFS.readFile('test/fixture/test001.coffee.json', 'utf-8')
            ]).then(([actual, expected]) ->
                expect(JSON.parse(expected)).to.eql JSON.parse(actual)
                do done
            ).catch((err) ->
                do err
            )

