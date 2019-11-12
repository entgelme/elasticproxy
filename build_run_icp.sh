#!/bin/sh -x
# Log in ONCE:
# cloudctl login
# docker login <icpcluster>:8500

# Change the names of the Container image registry BX_REGISTRY, 
# the k8s NAMESPACE to deploy to, and the App name and version tag 
# according to your needs:
BX_REGISTRY=mycluster.icp:8500
echo Using registry $BX_REGISTRY

NAMESPACE=kube-system
#NAMESPACE=default
echo Using k8s namespace $NAMESPACE

APPNAME=elasticproxy
APPVERSION=v1
echo Application is \'$APPNAME $APPVERSION\'

DOCKERTAG=$BX_REGISTRY/$NAMESPACE/$APPNAME:$APPVERSION
echo Docker tag: \'$DOCKERTAG\'

# build and push to IBM Cloud Private container image registry
docker build -t $DOCKERTAG .
docker push $DOCKERTAG 

# Create k8s deployment
kubectl delete svc,rc,deployments,pods,ingress -l app=$APPNAME -n $NAMESPACE
rm depltmp.yml
cat deployment.yml | sed s,"\$IMAGE",$DOCKERTAG,| sed s,"\$APPNAME",$APPNAME,>depltmp.yml
kubectl create -f depltmp.yml -n $NAMESPACE

# Create/Update ingress
rm $APPNAME-ingress.yml
cat APPNAME-ingress.yml | sed s,"\$APPNAME",$APPNAME,>$APPNAME-ingress.yml
kubectl apply -f $APPNAME-ingress.yml -n $NAMESPACE



