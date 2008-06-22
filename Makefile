## Licensed under the Apache License, Version 2.0 (the "License"); you may not
## use this file except in compliance with the License.  You may obtain a copy
## of the License at
##
##   http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
## WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
## License for the specific language governing permissions and limitations
## under the License.

RUN_TEST = /opt/local/lib/erlang/lib/common_test-1.3.0/priv/bin/run_test

all: subdirs

subdirs:
	cd src; make

test: test_do

test_compile: subdirs
	cd test; make

test_do: test_compile
	cp src/*.beam test/
	mkdir -p test/log
	${RUN_TEST} -dir . -logdir test/log

clean:	
	rm -rf *.beam erl_crash.dump *~
	rm -rf test/log
	cd src; make clean
	cd test; make clean