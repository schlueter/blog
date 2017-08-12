# Blog
This static web app is a simple blog which when hosted on GitHub and hooked up to Travis CI, will be automatically built and served with GitHub pages.

## Design Philosophy
Simplicity can be maintained by limiting dependencies, so I will try to minimize those. I'm eschewing use of node and its bloated ecosystem in favor of make and a few ubiquitous text manipulation tools and a sass compiler. As this is a *static* web app, I need only basic file serving capabilities which are provided for development purposes with the ubiquitous nginx. Travis and GitHub, as much as I would love to manage my own servers, provide build and web app hosting services __for free__, which I'll take for something which is not a critical application.

Reusability is also very beneficial, and is visible in both the provisioning, build, and application systems of this application. I don't like repeating myself, and have and will reuse components from my own and others' applications in this and future projects. To make that easier, parts of this application may be broken off to their own repositories, and dynamically included here.

Tangentiality of this and other things I build is caused by a desire to learn as much as I can about the parts of things I build. I build primarily to learn, and as I do not always have a goal in my learning, I frequently go down rabbit holes searching for how a thing works, or how I can integrate a new idea into existing systems or create new ones.

## Development
Run `make dev`. This will launch a VM and provision it such that it builds and serves the static application, and then watches the src directory for changes. The source html, sass, and javascript may then be edited, and the static application will be rebuilt when source files are saved.

## Build proces
See the source and comments in the [makefile](makefile).

## License and Copyright
Blog is licensed under the [GPLv3](GPL.txt).

## Author
Created by Brandon Schlueter<br/>
email: <b@schlueter.blue><br/>
gpg: 8C4854C3
