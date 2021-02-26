FROM ubuntu:20.04

ARG program_name

RUN mkdir /root/bug_bounty/
RUN mkdir /root/tools
COPY ./install.sh /root/install.sh
COPY ./create.sh /root/bug_bounty/create.sh
COPY ./recon_script/recon.sh /root/bug_bounty/recon.sh
RUN chmod +x /root/install.sh && /root/install.sh
RUN /root/bug_bounty/create.sh /root/bug_bounty/$program_name
RUN /root/bug_bounty/recon.sh /root/bug_bounty/$program_name /root/tools
