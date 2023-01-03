# Copyright (c) 2023, ARM Limited and Contributors. All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# Redistributions of source code must retain the above copyright notice, this
# list of conditions and the following disclaimer.
#
# Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# Neither the name of ARM nor the names of its contributors may be used
# to endorse or promote products derived from this software without specific
# prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.

ARG version
FROM ubuntu:$version
ENTRYPOINT ["/usr/bin/local/entrypoint.sh"]

# We expect the caller to invoke us as non-root so there is never a need for us
# to drop uid and gid.
# chmod 777 for all system files so that they can be accessed by nonroot users
# entrypoint.sh will...
#  (1) ...validate that it is running as uid!=0 and gid!=0.
#  (2) ...create a one-liner /etc/passwd matching that user (mainly because
#         this is needed by the 'ssh' command) and set the home as '/home'.
#  (3) ...exec requested CMD with arguments forwarded.

# this is the home shared by all users
ENV HOME="/home"

COPY requirements.sh .
RUN bash requirements.sh

RUN git config --global user.name "dummy-user" \
    && git config --global user.email "invalid-email" \
    && git config --global color.ui true

# 777 so that it is writeable by the non-root user
RUN wget https://storage.googleapis.com/git-repo-downloads/repo -O /usr/local/bin/repo \
    && chmod 777 /usr/local/bin/repo

RUN chmod -R 777 /home /etc/passwd /etc/group

COPY entrypoint.sh /usr/bin/local/entrypoint.sh
RUN chmod 555 /usr/bin/local/entrypoint.sh
