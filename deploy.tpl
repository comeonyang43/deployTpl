apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{.Name}}
  namespace: {{.Namespace}}
  labels:
    app: {{.Name}}
spec:
  replicas: {{.Replicas}}
  revisionHistoryLimit: {{.Revisions}}
  selector:
    matchLabels:
      app: {{.Name}}
  template:
    metadata:
      labels:
        app: {{.Name}}
    spec:{{if .ServiceAccount}}
      serviceAccountName: {{.ServiceAccount}}{{end}}
      containers:
      - name: {{.Name}}
        image: {{.Image}}
        - env:
            - name: TZ
              value: Asia/Shanghai
          envFrom:
            - configMapRef:
                name: nacos-env
        {{if .ImagePullPolicy}}imagePullPolicy: {{.ImagePullPolicy}}
        {{end}}ports:
        - containerPort: {{.Port}}
        readinessProbe:
          tcpSocket:
            port: {{.Port}}
          initialDelaySeconds: 5
          periodSeconds: 10
        livenessProbe:
          tcpSocket:
            port: {{.Port}}
          initialDelaySeconds: 15
          periodSeconds: 20
        resources:
          requests:
            cpu: {{.RequestCpu}}m
            memory: {{.RequestMem}}Mi
          limits:
            cpu: {{.LimitCpu}}m
            memory: {{.LimitMem}}Mi
        securityContext:
          runAsUser: 1000
        volumeMounts:
        - name: timezone
          mountPath: /etc/localtime
      {{if .Secret}}imagePullSecrets:
      - name: {{.Secret}}
      {{end}}volumes:
        - name: timezone
          hostPath:
            path: /usr/share/zoneinfo/Asia/Shanghai


---

apiVersion: v1
kind: Service
metadata:
  name: {{.Name}}-svc
  namespace: {{.Namespace}}
spec:
  ports:
  {{if .UseNodePort}}- nodePort: {{.NodePort}}
    port: {{.Port}}
    protocol: TCP
    targetPort: {{.TargetPort}}
  type: NodePort{{else}}- port: {{.Port}}
    targetPort: {{.TargetPort}}{{end}}
  selector:
    app: {{.Name}}
