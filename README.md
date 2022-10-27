# GitLab DevOps Trial Project/Repository

This repository is to test GitLab's pipeline for CI (Continuous Integration) and CD (Continuous Delivery).
This using **GitLab-Runner** on a virtual machine.

## The Application

The build is a simple 'HelloWorld' application build for Linux and for Windows.
Both using a CMake special tool-chain.

## Learning points from the Trial

1. Auto compile on VM after new Git push on 'staging' branch.
2. Reporting in GitLab when compile failure. 
3. Reporting in GitLab when unit-tests fail.
4. Build a Debian package after a push on the 'release' branch. (maybe Windows too)