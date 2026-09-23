library(lme4)

load("C:/Users/pete/Dropbox/cdd/data/groupleveldataframe.rdata")
attach(data)


# kyu data
cor(subset(cbind(data$salience.T1PK, data$abs.net.change), data$poll.id != "Bulgaria" & 
                                                          data$poll.id != "China" & 
                                                          data$poll.id != "Greece" & 
                                                          data$poll.id != "New Haven" &
                                                          data$poll.id != "nic1" &
                                                          data$poll.id != "swepco" & 
                                                          data$poll.id != "wtu"))

# mohanty data

cor(subset(cbind(data$salience.T1PK, data$abs.net.change), data$poll.id != "Bulgaria" | 
  data$poll.id == "China" |
  data$poll.id == "Greece" | 
  data$poll.id == "New Haven" |
  data$poll.id == "nic1" |
  data$poll.id == "swepco" | 
  data$poll.id == "wtu"))

cor(abs.net.change, salience.T1PK)
by(abs.net.change, country, mean)

by(cbind(abs.net.change, salience.T1PK), country, cor)

library(calibrate)
tmp <- by(salience.T1PK, poll.id, mean)
salience <- c(tmp[1:6], tmp[8:11], tmp[13:14], tmp[17:21])
tmp <- by(abs.net.change, poll.id, mean)
mean.abs.net.change <- c(tmp[1:6], tmp[8:11], tmp[13:14], tmp[17:21])
labs <- sort(unique(poll.id))
cor(subset(cbind(data$salience.T1PK, data$abs.net.change), data$poll.id != "swepco" & data$poll.id != "wtu"))

plot(salience, mean.abs.net.change, xlab="Salience as Mean T1 K from entire sample", ylab="Mean Absolute Net Change (group level)")
textxy(salience, mean.abs.net.change, labs, cx=.5)

tmp <- subset(cbind(data$salience.T1PK, data$abs.net.change), data$poll.id == "swepco" | 
  data$poll.id == "wtu")

summary(lm(abs.net.change ~ salience.T1PK))
summary(lm(abs.net.change ~ salience.T1PK + diversity + extremity))
summary(lm(abs.net.change ~ salience.T1PK + diversity + extremity + online + FP + US))
summary(lm(abs.net.change ~ salience.T1PK + diversity + extremity + online + FP + factor(country)))


summary(lm(net.change ~ salience.T1PK + diversity + extremity + online + FP + US+diversity*extremity))

summary(lm(net.change ~ salience.T1PK + diversity + extremity + online + FP + factor(country)+diversity*extremity))

k2 <- salience.T1PK^2
quadratic <- lm(net.change ~ salience.T1PK + k2 + diversity + extremity + online + FP + factor(country), x=TRUE)
summary(quadratic)
x <- c(2410:7340)/10000
plot(y=-.77+3.39*x-2.64*x^2 + sum(colMeans(out$x[,4:12]) * b[4:12]), c(2410:7340)/10000, ylab="net change", xlab="T1 Mean K (all respondents)")

k2.by.group <- salience.T1PK.by.group^2
quadratic <- lm(net.change ~ salience.T1PK.by.group + k2.by.group + diversity + extremity + online + FP + factor(country), x=TRUE)
summary(quadratic)


summary(lm(net.change ~ local + diversity + extremity + online + FP + factor(country)+diversity*extremity))
summary(lm(net.change ~ local + salience.T1PK + diversity + extremity + online + FP + factor(country)+diversity*extremity))
summary(lm(net.change ~ local + salience.T1PK + k2 + diversity + extremity + online + FP + factor(country)+diversity*extremity))


out <- lm(net.change ~ salience.T1PK + diversity + extremity + online + FP + factor(country), x=TRUE)
cor(out$x[,2:11])
out <- lm(net.change ~ salience.T1PK + diversity + online + FP + factor(country), x=TRUE)
out <- lm(net.change ~ salience.T1PK + extremity + online + FP + factor(country), x=TRUE)
out <- lm(net.change ~ salience.T1PK +salience.T1PK.by.group + diversity + extremity + online + FP + factor(country), x=TRUE)
out <- lm(net.change ~ salience.T1PK.by.group + diversity + extremity + online + FP + factor(country), x=TRUE)
out <- lm(net.change ~ local + diversity + extremity + online + FP + factor(country), x=TRUE)
summary(out)


# to-do consider multilevel model - issues within polls within countries, groups non-nested (?)
# need better classification of issues (not just FP v domestic, but local, maybe election as separate...)




summary(lm(net.change ~ salience.T1PK + diversity + extremity + online + FP + factor(country)))
summary(lm(net.change ~ salience.T1PK + diversity + extremity + online + FP + factor(country)+diversity*extremity))

summary(lm(polarized ~ salience.T1PK + diversity + extremity + online + FP + factor(country)))
summary(lm(polarized ~ salience.T1PK + diversity + extremity + online + FP + factor(country)+diversity*extremity))

summary(lm(homogenization ~ salience.T1PK + diversity + extremity + online + FP + factor(country)))
summary(lm(homogenization ~ salience.T1PK + diversity + extremity + online + FP + factor(country)+diversity*extremity))
