# TLSAssistant Testbed

The TLSAssistant Testbed is an open source code for automatically configuring various vulnerable webservers for the purpose of testing TLSAssistant analysis modules.

## Installation

### One Liner

To run the code, execute the following command:
```bash
sudo apt update && sudo apt-get -y install git && git clone https://github.com/stfbk/tlsassistant-testbed && cd tlsassistant-testbed && chmod +x run.sh && sudo ./run.sh
```
---
### Step by Step
If you want to download and install by executing every step:
<details>

<summary>Show single steps</summary>

0. Install git
```bash
sudo apt update && sudo apt-get -y install git
```
1. Download the tool by running
```bash
git clone https://github.com/stfbk/tlsassistant-testbed && cd tlsassistant-testbed
```
2. Allow execution for the file:
```bash
chmod +x run.sh
```
3. Run the run.sh script:
```bash
sudo ./run.sh
```
</details>

### Docker

Recommended for non-Ubuntu users:

Since it does use APT and install dependencies, we can use the Dockerfile to build the image and contain the installation process.

<details>
<summary>Docker build and run tutorial</summary>
Clone the repository:

```bash
  git clone https://github.com/stfbk/tlsassistant-testbed && cd tlsassistant-testbed
```
Build the docker image:
```bash
  docker build -t tlsassistant-testbed .
```
Run the docker image mapping all of the ports:

```bash
  docker run -p 9000:9000 -p 9001:9001 -p 9002:9002 -p 9003:9003 -p 9004:9004 -p 9005:9005 -p 9006:9006 -p 9007:9007 -t tlsassistant-testbed
```
</details>

## Features

<details>

<summary> Supported Vulnerabilities </summary> 

- 3SHAKE
- BEAST
- BREACH
- CCS Injection
- Certificate Transparency
- CRIME
- DROWN
- FREAK
- Heartbleed
- HSTS preloading
- HSTS set
- HTTPS enforced
- LOGJAM
- LUCKY13
- BAR MITZVAH
- RC4 NOMORE
- Perfect Forward Secrecy
- POODLE
- SSL RENEGOTIATION
- ROBOT
- SWEET32
 
<!-- ######### - ALPACA ######## --> 
<!-- ######### - RACCOON ####### --> 
<!-- ######### - SLOTH ######### --> 
<!-- ######### - TICKETBLEED ### -->

</details>

<details>
<summary> Ports configured </summary>

- port 9000 == DROWN, RC4 NOMORE, BAR MITZVAH, Secure Renegotiation Missing, Secure Client-Initiated Renegotiation
- port 9001 == SWEET32, LUCKY13, FREAK, LOGJAM
- port 9002 == DROWN, SWEET32, Secure Renegotiation Missing, Secure Client-Initiated Renegotiation
- port 9003 == BEAST, POODLE (SSL), SWEET32, FREAK, LOGJAM, LUCKY13
- port 9004 == FREAK, RC4 NOMORE, BAR MITZVAH, LOGJAM
- port 9005 == Heartbleed, CCS, FREAK, LOGJAM, RC4   
- port 9006 == ROBOT
- port 9007 == CRIME, BREACH, LUCKY13

</details>

<details>
<summary> Webservers </summary>

- Nginx 1.9.0 with openssl 1.0.1u
- Nginx 1.9.0 with openssl 1.0.1a with patched doc files
- DamnVulnerableOpenSSL Docker 
- Apache httpd 2.4.37 patched with apr-1.6.5, apr-util-1.6.1 and using openssl 1.0.2-stable

</details>

## License

```
Copyright 2024, Fondazione Bruno Kessler

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```

Developed within the [Security & Trust](https://st.fbk.eu/) research unit, part of the [Center for Cybersecurity](https://cs.fbk.eu/)  at [Fondazione Bruno Kessler](https://www.fbk.eu/en/) (Italy)
